local Base = require('render-markdown.render.base')
local Parser = require('render-markdown.parser.table')
local iter = require('render-markdown.lib.iter')
local str = require('render-markdown.lib.str')

---@class render.md.render.Table: render.md.Render
---@field private config render.md.table.Config
---@field private data render.md.table.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.pipe_table
    if not self.config.enabled then
        return false
    end
    local parser = Parser.new(self.context, self.config)
    local data = parser:parse(self.node)
    if not data then
        return false
    end
    self.data = data
    return true
end

---@protected
function Render:run()
    self:delimiter()
    for _, row in ipairs(self.data.rows) do
        self:row(row)
    end
    if self.config.border_enabled and self.data.layout.valid then
        self:border()
    end
end

---@private
function Render:delimiter()
    local delim = self.data.delim
    local border = self.config.border
    local indicator = self.config.alignment_indicator

    local icon = border[11]
    local parts = iter.list.map(self.data.cols, function(col)
        -- must have enough space to put the alignment indicator
        -- alignment indicator must be exactly one character wide
        -- do not put an indicator for default alignment
        local add_indicator = col.width >= 3
            and str.width(indicator) == 1
            and col.alignment ~= Parser.Alignment.default
        if not add_indicator then
            return icon:rep(col.width)
        end
        if col.alignment == Parser.Alignment.left then
            return indicator .. icon:rep(col.width - 1)
        elseif col.alignment == Parser.Alignment.right then
            return icon:rep(col.width - 1) .. indicator
        else
            return indicator .. icon:rep(col.width - 2) .. indicator
        end
    end)
    local delimiter = border[4] .. table.concat(parts, border[5]) .. border[6]

    local line = self:line()
    line:pad(str.spaces('start', delim.text))
    line:text(delimiter, self.config.head)
    line:pad(str.width(delim.text) - line:width())
    self.marks:over(self.config, 'table_border', delim, {
        virt_text = line:get(),
        virt_text_pos = 'overlay',
    })
end

---@private
---@param row render.md.table.Row
function Render:row(row)
    local icon = self.config.border[10]
    local header = row.node.type == 'pipe_table_header'
    local highlight = header and self.config.head or self.config.row

    if vim.tbl_contains({ 'trimmed', 'padded', 'raw' }, self.config.cell) then
        for _, pipe in ipairs(row.pipes) do
            self.marks:over(self.config, 'table_border', pipe, {
                virt_text = { { icon, highlight } },
                virt_text_pos = 'overlay',
            })
        end
    end

    if vim.tbl_contains({ 'trimmed', 'padded' }, self.config.cell) then
        for i, cell in ipairs(row.cells) do
            local left, right = self:shifts(self.data.cols[i], cell)
            self:shift(cell.node, 'left', left)
            self:shift(cell.node, 'right', right)
        end
    elseif self.config.cell == 'overlay' then
        self.marks:over(self.config, 'table_border', row.node, {
            virt_text = { { row.node.text:gsub('|', icon), highlight } },
            virt_text_pos = 'overlay',
        })
    end
end

---@private
---@param col render.md.table.Col
---@param cell render.md.table.row.Cell
---@return integer, integer
function Render:shifts(col, cell)
    local space = cell.space
    local fill = col.width - cell.width
    -- delim(20) : --------------------
    -- col(4,7,2): ----XXXXXXX--
    -- fill(7)   :              _______
    if not self.context.conceal:enabled() then
        -- result: ----XXXXXXX--_______
        -- without concealing it is impossible to do full alignment
        return 0, fill
    elseif col.alignment == Parser.Alignment.center then
        -- (7 + 2 - 4) // 2 = 5 // 2 = 2 -> move two spaces to the right
        -- result: __----XXXXXXX--_____
        local shift = math.floor((fill + space.right - space.left) / 2)
        return shift, fill - shift
    elseif col.alignment == Parser.Alignment.right then
        -- 2 - 1 = 1 -> conceal one space on right side
        -- result: -_______----XXXXXXX-
        local shift = space.right - self.config.padding
        return fill + shift, -shift
    else
        -- 4 - 1 = 3 -> conceal three spaces on left side
        -- result: -XXXXXXX--_______---
        local shift = space.left - self.config.padding
        return -shift, fill + shift
    end
end

---Use low priority to include pipe marks
---@private
---@param node render.md.Node
---@param side 'left'|'right'
---@param amount integer
function Render:shift(node, side, amount)
    local col = side == 'left' and node.start_col or node.end_col
    if amount > 0 then
        self.marks:add(self.config, true, node.start_row, col, {
            priority = 0,
            virt_text = self:line():pad(amount):get(),
            virt_text_pos = 'inline',
        })
    elseif amount < 0 then
        amount = amount - self.context.conceal:width('', 1)
        self.marks:add(self.config, true, node.start_row, col + amount, {
            priority = 0,
            end_col = col,
            conceal = '',
        })
    end
end

---@private
function Render:border()
    local rows = self.data.rows
    local border = self.config.border

    ---@param row render.md.table.Row
    ---@return boolean
    local function width_equal(row)
        if vim.tbl_contains({ 'trimmed', 'padded' }, self.config.cell) then
            -- assume table was modified to match
            return true
        elseif self.config.cell == 'raw' then
            -- want the computed widths to match
            for i, cell in ipairs(row.cells) do
                if cell.width ~= self.data.cols[i].width then
                    return false
                end
            end
            return true
        elseif self.config.cell == 'overlay' then
            -- want the underlying text widths to match
            return str.width(row.node.text) == str.width(self.data.delim.text)
        else
            return false
        end
    end

    local first = rows[1]
    local last = rows[#rows]
    if not width_equal(first) or not width_equal(last) then
        return
    end

    local icon = border[11]
    local parts = iter.list.map(self.data.cols, function(col)
        return icon:rep(col.width)
    end)

    ---@param node render.md.Node
    ---@param above boolean
    ---@param chars [string, string, string]
    local function table_border(node, above, chars)
        local text = chars[1] .. table.concat(parts, chars[2]) .. chars[3]
        local highlight = above and self.config.head or self.config.row
        local line = self:line():pad(self.data.layout.col):text(text, highlight)

        local virtual = self.config.border_virtual
        local row, target = node:line(above and 'above' or 'below', 1)
        local available = target and str.width(target) == 0

        if not virtual and available and self.context.used:take(row) then
            self.marks:add(self.config, 'table_border', row, 0, {
                virt_text = line:get(),
                virt_text_pos = 'overlay',
            })
        else
            self.marks:add(self.config, 'virtual_lines', node.start_row, 0, {
                virt_lines = { self:indent():line(true):extend(line):get() },
                virt_lines_above = above,
            })
        end
    end

    table_border(first.node, true, { border[1], border[2], border[3] })
    if #rows > 1 then
        table_border(last.node, false, { border[7], border[8], border[9] })
    end
end

return Render
