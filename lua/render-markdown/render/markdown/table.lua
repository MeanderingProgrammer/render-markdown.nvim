local Base = require('render-markdown.render.base')
local Iter = require('render-markdown.lib.iter')
local Str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')

---@class render.md.table.Data
---@field delim render.md.table.DelimRow
---@field rows render.md.table.Row[]

---@class render.md.table.DelimRow
---@field node render.md.Node
---@field cols render.md.table.DelimCol[]

---@class render.md.table.DelimCol
---@field width integer
---@field alignment render.md.table.Alignment

---@enum render.md.table.Alignment
local Alignment = {
    left = 'left',
    right = 'right',
    center = 'center',
    default = 'default',
}

---@class render.md.table.Row
---@field node render.md.Node
---@field pipes render.md.Node[]
---@field cols render.md.table.Col[]

---@class render.md.table.Col
---@field row integer
---@field start_col integer
---@field end_col integer
---@field width integer
---@field space render.md.table.Space

---@class render.md.table.Space
---@field left integer
---@field right integer

---@class render.md.render.Table: render.md.Render
---@field private config render.md.table.Config
---@field private data render.md.table.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.pipe_table
    if self.context:skip(self.config) then
        return false
    end
    if self.config.style == 'none' then
        return false
    end
    if self.node:get():has_error() then
        return false
    end

    -- ensure delimiter and rows exist
    local delim_node = nil ---@type render.md.Node?
    local row_nodes = {} ---@type render.md.Node[]
    self.node:for_each_child(function(node)
        if node.type == 'pipe_table_delimiter_row' then
            delim_node = node
        elseif self.context.view:overlaps(node:get()) then
            local row_types = { 'pipe_table_header', 'pipe_table_row' }
            if vim.tbl_contains(row_types, node.type) then
                row_nodes[#row_nodes + 1] = node
            else
                log.unhandled_type('markdown', 'row', node.type)
            end
        end
    end)
    if not delim_node or #row_nodes == 0 then
        return false
    end

    -- double check delimiter exists after parsing
    local delim = self:parse_delim(delim_node)
    if not delim then
        return false
    end

    -- double check rows exist after parsing
    local rows = {} ---@type render.md.table.Row[]
    table.sort(row_nodes)
    for _, row_node in ipairs(row_nodes) do
        local row = self:parse_row(row_node, #delim.cols)
        if row then
            rows[#rows + 1] = row
        end
    end
    if #rows == 0 then
        return false
    end

    -- store the max width in the delimiter
    for _, row in ipairs(rows) do
        for i, col in ipairs(row.cols) do
            local space = col.space.left + col.space.right
            local available = space - (2 * self.config.padding)
            -- if we don't have enough space for padding add it to the width
            local width = col.width
            if available < 0 then
                width = width - available
            end
            if self.config.cell == 'trimmed' then
                width = width - math.max(available, 0)
            end
            local delim_col = delim.cols[i]
            delim_col.width = math.max(delim_col.width, width)
        end
    end

    self.data = { delim = delim, rows = rows }

    return true
end

---@private
---@param node render.md.Node
---@return render.md.table.DelimRow?
function Render:parse_delim(node)
    local pipes, cells = Render.parse_cells(node, 'pipe_table_delimiter_cell')
    if not pipes or not cells then
        return nil
    end
    local cols = {} ---@type render.md.table.DelimCol[]
    for i, cell in ipairs(cells) do
        local start_col, end_col = pipes[i].end_col, pipes[i + 1].start_col
        local width = end_col - start_col
        assert(width >= 0, 'invalid table layout')
        if self.config.cell == 'padded' then
            width = math.max(width, self.config.min_width)
        elseif self.config.cell == 'trimmed' then
            width = self.config.min_width
        end
        cols[#cols + 1] = {
            width = width,
            alignment = Render.alignment(cell),
        }
    end
    ---@type render.md.table.DelimRow
    return { node = node, cols = cols }
end

---@private
---@param node render.md.Node
---@return render.md.table.Alignment
function Render.alignment(node)
    local has_left = node:child('pipe_table_align_left') ~= nil
    local has_right = node:child('pipe_table_align_right') ~= nil
    if has_left and has_right then
        return Alignment.center
    elseif has_left then
        return Alignment.left
    elseif has_right then
        return Alignment.right
    else
        return Alignment.default
    end
end

---@private
---@param node render.md.Node
---@param num_cols integer
---@return render.md.table.Row?
function Render:parse_row(node, num_cols)
    local pipes, cells = Render.parse_cells(node, 'pipe_table_cell')
    if not pipes or not cells or #cells ~= num_cols then
        return nil
    end
    local cols = {} ---@type render.md.table.Col[]
    for i, cell in ipairs(cells) do
        -- account for double width glyphs by replacing cell range with width
        local start_col, end_col = pipes[i].end_col, pipes[i + 1].start_col
        local width = end_col - start_col
        width = width
            - (cell.end_col - cell.start_col)
            + self.context:width(cell)
        assert(width >= 0, 'invalid table layout')
        cols[#cols + 1] = {
            row = cell.start_row,
            start_col = cell.start_col,
            end_col = cell.end_col,
            width = width,
            space = {
                -- gap between the cell start and the pipe start
                left = math.max(cell.start_col - start_col, 0),
                -- attached to the end of the cell itself
                right = math.max(Str.spaces('end', cell.text), 0),
            },
        }
    end
    ---@type render.md.table.Row
    return { node = node, pipes = pipes, cols = cols }
end

---@private
---@param node render.md.Node
---@param cell string
---@return render.md.Node[]?, render.md.Node[]?
function Render.parse_cells(node, cell)
    local pipes = {} ---@type render.md.Node[]
    local cells = {} ---@type render.md.Node[]
    node:for_each_child(function(child)
        if child.type == '|' then
            pipes[#pipes + 1] = child
        elseif child.type == cell then
            cells[#cells + 1] = child
        else
            log.unhandled_type('markdown', 'cell', child.type)
        end
    end)
    if #pipes == 0 or #cells == 0 or #pipes ~= #cells + 1 then
        return nil, nil
    end
    table.sort(pipes)
    table.sort(cells)
    return pipes, cells
end

---@protected
function Render:run()
    self:delimiter()
    for _, row in ipairs(self.data.rows) do
        self:row(row)
    end
    if self.config.style == 'full' then
        self:border()
    end
end

---@private
function Render:delimiter()
    local delim, border = self.data.delim, self.config.border

    local indicator, icon = self.config.alignment_indicator, border[11]
    local parts = Iter.list.map(delim.cols, function(col)
        -- must have enough space to put the alignment indicator
        -- alignment indicator must be exactly one character wide
        -- do not put an indicator for default alignment
        local add_indicator = col.width >= 3
            and Str.width(indicator) == 1
            and col.alignment ~= Alignment.default
        if not add_indicator then
            return icon:rep(col.width)
        end
        if col.alignment == Alignment.left then
            return indicator .. icon:rep(col.width - 1)
        elseif col.alignment == Alignment.right then
            return icon:rep(col.width - 1) .. indicator
        else
            return indicator .. icon:rep(col.width - 2) .. indicator
        end
    end)
    local delimiter = border[4] .. table.concat(parts, border[5]) .. border[6]

    local line = self:line()
    line:pad(Str.spaces('start', delim.node.text))
    line:text(delimiter, self.config.head)
    line:pad(Str.width(delim.node.text) - Str.line_width(line:get()))
    self.marks:over('table_border', delim.node, {
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
            self.marks:over('table_border', pipe, {
                virt_text = { { icon, highlight } },
                virt_text_pos = 'overlay',
            })
        end
    end

    if vim.tbl_contains({ 'trimmed', 'padded' }, self.config.cell) then
        for i, col in ipairs(row.cols) do
            local delim_col = self.data.delim.cols[i]
            -- amount of space needed to get column to target width
            local fill = delim_col.width - col.width
            if not self.context.conceal:enabled() then
                -- without concealing it is impossible to do full alignment
                self:shift(col, 'right', fill)
            elseif delim_col.alignment == Alignment.center then
                local shift =
                    math.floor((fill + col.space.right - col.space.left) / 2)
                self:shift(col, 'left', shift)
                self:shift(col, 'right', fill - shift)
            elseif delim_col.alignment == Alignment.right then
                local shift = col.space.right - self.config.padding
                self:shift(col, 'left', fill + shift)
                self:shift(col, 'right', -shift)
            else
                local shift = col.space.left - self.config.padding
                self:shift(col, 'left', -shift)
                self:shift(col, 'right', fill + shift)
            end
        end
    elseif self.config.cell == 'overlay' then
        self.marks:over('table_border', row.node, {
            virt_text = { { row.node.text:gsub('|', icon), highlight } },
            virt_text_pos = 'overlay',
        })
    end
end

---Use low priority to include pipe marks
---@private
---@param col render.md.table.Col
---@param side 'left'|'right'
---@param amount integer
function Render:shift(col, side, amount)
    local column = side == 'left' and col.start_col or col.end_col
    if amount > 0 then
        self.marks:add(true, col.row, column, {
            priority = 0,
            virt_text = self:line():pad(amount, self.config.filler):get(),
            virt_text_pos = 'inline',
        })
    elseif amount < 0 then
        amount = amount - self.context.conceal:width('')
        self.marks:add(true, col.row, column + amount, {
            priority = 0,
            end_col = column,
            conceal = '',
        })
    end
end

---@private
function Render:border()
    local delim = self.data.delim
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
            for i, col in ipairs(row.cols) do
                if delim.cols[i].width ~= col.width then
                    return false
                end
            end
            return true
        elseif self.config.cell == 'overlay' then
            -- want the underlying text widths to match
            return Str.width(delim.node.text) == Str.width(row.node.text)
        else
            return false
        end
    end

    local first, last = rows[1], rows[#rows]
    if not width_equal(first) or not width_equal(last) then
        return
    end

    ---@param node render.md.Node
    ---@return integer
    local function get_spaces(node)
        local _, line = node:line('first', 0)
        return math.max(Str.spaces('start', line or ''), node.start_col)
    end

    local first_node = first.node
    local last_node = #rows == 1 and delim.node or last.node
    local spaces = get_spaces(first_node)
    if spaces ~= get_spaces(last_node) then
        return
    end

    local sections = Iter.list.map(delim.cols, function(col)
        return border[11]:rep(col.width)
    end)

    ---@param node render.md.Node
    ---@param above boolean
    ---@param chars { [1]: string, [2]: string, [3]: string }
    local function table_border(node, above, chars)
        local text = chars[1] .. table.concat(sections, chars[2]) .. chars[3]
        local highlight = above and self.config.head or self.config.row
        local line = self:line():pad(spaces):text(text, highlight)

        local virtual = self.config.border_virtual
        local row, target = node:line(above and 'above' or 'below', 1)
        local available = target and Str.width(target) == 0

        if not virtual and available and self.context.used:take(row) then
            self.marks:add('table_border', row, 0, {
                virt_text = line:get(),
                virt_text_pos = 'overlay',
            })
        else
            self.marks:add(false, node.start_row, 0, {
                virt_lines = { self:indent():line(true):extend(line):get() },
                virt_lines_above = above,
            })
        end
    end

    table_border(first_node, true, { border[1], border[2], border[3] })
    if #rows > 1 then
        table_border(last_node, false, { border[7], border[8], border[9] })
    end
end

return Render
