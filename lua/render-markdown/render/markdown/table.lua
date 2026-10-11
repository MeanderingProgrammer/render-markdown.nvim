local Base = require('render-markdown.render.base')
local Parser = require('render-markdown.parser.table')
local env = require('render-markdown.lib.env')
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
    local data = parser:parse(self.node, self.marks)
    if not data then
        return false
    end
    self.data = data
    return true
end

---@protected
function Render:run()
    self:delimiter()
    local wrapped = {} ---@type table<integer, render.md.mark.Line[]>
    local latex = {} ---@type table<integer, render.md.request.latex.Row>
    for i, row in ipairs(self.data.rows) do
        if self.data.layout.wrap and not self:row_fits(row) then
            wrapped[i] = self:wrapped_row(row)
        else
            self:row(row)
        end
        latex[i] = self.context.latex:take_row(row.node.start_row)
        if latex[i] then
            self:latex(row, latex[i], wrapped[i])
        end
    end
    if self.config.border_enabled and self.data.layout.valid then
        self:border(wrapped, latex)
    end
    for i, row in ipairs(self.data.rows) do
        local lines = wrapped[i]
        if lines then
            self.marks:replace(self.config, row.node, lines)
        end
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

    if self.data.layout.wrap and env.win.get(self.context.win, 'wrap') then
        local _, source = delim:line('first', 0)
        local width = str.width(source) + self:indent():size()
        if width > env.win.width(self.context.win) then
            local line = self:line()
            line:extend(self.data.prefixes[delim.start_row])
            line:text(delimiter, self.config.head)
            self.marks:replace(self.config, delim, { line:get() })
            return
        end
    end
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
---@param row render.md.table.Row
---@return boolean
function Render:row_fits(row)
    local added = self.context.inline:width(row.node)
    for i, cell in ipairs(row.cells) do
        local col = self.data.cols[i]
        local units = assert(cell.units, 'missing cell units')
        local width = Parser.measure(units)
        if width + 2 * self.config.padding > col.width then
            return false
        end
        local left, right = self:shifts(col, cell)
        if width ~= cell.width - cell.space.left - cell.space.right then
            return false
        end
        added = added + math.max(left, 0) + math.max(right, 0) ---@type integer
    end
    if env.win.get(self.context.win, 'wrap') then
        local _, source = row.node:line('first', 0)
        local width = str.width(source) + self:indent():size() + added
        return width <= env.win.width(self.context.win)
    end
    return true
end

---@private
---@param row render.md.table.Row
---@return render.md.mark.Line[]
function Render:wrapped_row(row)
    local prefixes = self.data.prefixes
    local padding = self.config.padding
    local icon = self.config.border[10]
    local header = row.node.type == 'pipe_table_header'
    local highlight = header and self.config.head or self.config.row

    local cells = {} ---@type render.md.mark.Line[][]
    local height = 1
    for i, cell in ipairs(row.cells) do
        local col = self.data.cols[i]
        local units = assert(cell.units, 'missing cell units')
        cells[i] = Parser.wrap(units, col.width - 2 * padding)
        height = math.max(height, #cells[i])
    end

    local lines = {} ---@type render.md.mark.Line[]
    for fragment = 1, height do
        local line = self:line()
            :extend(prefixes[row.node.start_row])
            :text(icon, highlight)
        for i, col in ipairs(self.data.cols) do
            local cell = Parser.align(
                cells[i][fragment] or {},
                col.width,
                col.alignment,
                padding,
                highlight
            )
            line:extend(cell)
            line:text(icon, highlight)
        end
        lines[#lines + 1] = line:get()
    end
    return lines
end

---@class render.md.table.latex.Placed
---@field offset integer display column within the cell
---@field item render.md.request.latex.Item

---Take over the virtual lines latex added for multi-line formulas in a row,
---so they are framed by the table and each formula lines up with its cell
---@private
---@param row render.md.table.Row
---@param latex render.md.request.latex.Row
---@param wrapped? render.md.mark.Line[]
function Render:latex(row, latex, wrapped)
    local placed, widths = self:latex_place(row, latex, wrapped ~= nil)
    if next(placed) == nil then
        -- nothing lines up with a cell, keep the lines latex added
        return
    end
    if not wrapped then
        local prefix = self:indent():line(true):pad(row.node:col())
        if latex.above then
            latex.above.opts.virt_lines =
                self:latex_lines(row, prefix, latex, placed[1], widths, true)
        end
        if latex.below then
            latex.below.opts.virt_lines =
                self:latex_lines(row, prefix, latex, placed[1], widths, false)
        end
        return
    end
    -- row is replaced by virtual lines, so ours go around each fragment of it
    local prefix = self:line():extend(self.data.prefixes[row.node.start_row])
    if latex.above then
        latex.above.opts.virt_lines = {}
    end
    if latex.below then
        latex.below.opts.virt_lines = {}
    end
    -- go backwards so inserting lines does not shift remaining fragments
    for fragment = #wrapped, 1, -1 do
        local cells = placed[fragment]
        if cells then
            local below =
                self:latex_lines(row, prefix, latex, cells, widths, false)
            for i, line in ipairs(below) do
                table.insert(wrapped, fragment + i, line)
            end
            local above =
                self:latex_lines(row, prefix, latex, cells, widths, true)
            for i, line in ipairs(above) do
                table.insert(wrapped, fragment + i - 1, line)
            end
        end
    end
end

---Places each formula within its cell, grouped by the wrapped fragment it
---ends up on (always the first one when the row is not wrapped)
---@private
---@param row render.md.table.Row
---@param latex render.md.request.latex.Row
---@param wrapped boolean
---@return table<integer, render.md.table.latex.Placed[][]>, integer[]
function Render:latex_place(row, latex, wrapped)
    local padding = self.config.padding
    local shifted = vim.tbl_contains({ 'trimmed', 'padded' }, self.config.cell)
    local _, source = row.node:line('first', 0)

    local placed = {} ---@type table<integer, render.md.table.latex.Placed[][]>
    local widths = {} ---@type integer[]
    for i, cell in ipairs(row.cells) do
        local col = self.data.cols[i]
        widths[i] = (wrapped or shifted) and col.width or cell.width

        local lines, starts ---@type render.md.mark.Line[]?, integer[]?
        local units = cell.units
        if wrapped and units then
            lines, starts = Parser.wrap(units, col.width - 2 * padding)
        end

        for _, item in ipairs(latex.items) do
            local node = item.node
            if
                node.start_col >= cell.node.start_col
                and node.end_col <= cell.node.end_col
            then
                -- display width of the cell text in front of the formula
                local before = self.context:width({
                    text = (source or ''):sub(
                        cell.node.start_col + 1,
                        node.start_col
                    ),
                    start_row = node.start_row,
                    start_col = cell.node.start_col,
                    end_row = node.start_row,
                    end_col = node.start_col,
                })

                local fragment, offset = 1, 0
                if units and lines and starts then
                    -- wrapped units start after leading spaces of the cell
                    before = before - str.spaces('start', cell.node.text)
                    local unit, width = 1, 0
                    while unit <= #units and width < before do
                        width = width + units[unit].width
                        unit = unit + 1
                    end
                    while
                        starts[fragment + 1]
                        and starts[fragment + 1] <= unit
                    do
                        fragment = fragment + 1
                    end
                    for j = starts[fragment], unit - 1 do
                        offset = offset + units[j].width
                    end
                    -- same alignment as Parser.align
                    local extra = col.width
                        - 2 * padding
                        - str.line_width(lines[fragment])
                    if col.alignment == Parser.Alignment.right then
                        offset = offset + extra
                    elseif col.alignment == Parser.Alignment.center then
                        offset = offset + math.floor(extra / 2)
                    end
                    offset = offset + padding
                elseif shifted then
                    local left = self:shifts(col, cell)
                    offset = cell.space.left + left + before
                else
                    offset = cell.space.left + before
                end

                if not placed[fragment] then
                    placed[fragment] = {}
                end
                local cells = placed[fragment]
                if not cells[i] then
                    cells[i] = {}
                end
                cells[i][#cells[i] + 1] = { offset = offset, item = item }
            end
        end
    end
    return placed, widths
end

---@private
---@param row render.md.table.Row
---@param prefix render.md.Line
---@param latex render.md.request.latex.Row
---@param cells render.md.table.latex.Placed[][]
---@param widths integer[]
---@param above boolean
---@return render.md.mark.Line[]
function Render:latex_lines(row, prefix, latex, cells, widths, above)
    local icon = self.config.border[10]
    local header = row.node.type == 'pipe_table_header'
    local highlight = header and self.config.head or self.config.row

    ---@param item render.md.request.latex.Item
    ---@return string[]
    local function fragments(item)
        return above and item.above or item.below
    end

    local height = 0
    for _, values in pairs(cells) do
        for _, value in ipairs(values) do
            height = math.max(height, #fragments(value.item))
        end
    end

    local lines = {} ---@type render.md.mark.Line[]
    for l = 1, height do
        local line = prefix:copy():text(icon, highlight)
        for i, width in ipairs(widths) do
            local cell = self:line()
            local current = 0
            for _, value in ipairs(cells[i] or {}) do
                local item = value.item
                local position = math.max(value.offset, current)
                position = math.max(math.min(position, width - item.width), 0)
                -- above lines are aligned to the bottom, below lines to the top
                local index = above and l - (height - #fragments(item)) or l
                local body = fragments(item)[index]
                if body then
                    cell:pad(position - cell:width())
                    cell:text(body, latex.highlight)
                end
                -- keep at least one space between formulas
                current = position + item.width + 1
            end
            cell = cell:sub(1, width)
            line:extend(cell):pad(width - cell:width()):text(icon, highlight)
        end
        lines[#lines + 1] = line:get()
    end
    return lines
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
---@param wrapped table<integer, render.md.mark.Line[]>
---@param latex table<integer, render.md.request.latex.Row>
function Render:border(wrapped, latex)
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

    ---@param index integer
    ---@param above boolean
    ---@param chars [string, string, string]
    local function table_border(index, above, chars)
        local item = rows[index]
        local text = chars[1] .. table.concat(parts, chars[2]) .. chars[3]
        local highlight = above and self.config.head or self.config.row
        local line = self:line():pad(self.data.layout.col):text(text, highlight)

        local virtual = self.config.border_virtual
        local row, target = item.node:line(above and 'above' or 'below', 1)
        local available = target and str.width(target) == 0

        if not virtual and available and self.context.used:take(row) then
            self.marks:add(self.config, 'table_border', row, 0, {
                virt_text = line:get(),
                virt_text_pos = 'overlay',
            })
        else
            local virtual_line = self:indent():line(true):extend(line):get()
            local lines = wrapped[index]
            local mark = latex[index]
                and latex[index][above and 'above' or 'below']
            if not lines and mark then
                -- keep border outside of the latex lines framed by the table
                lines = mark.opts.virt_lines
            end
            if lines then
                table.insert(lines, above and 1 or #lines + 1, virtual_line)
            else
                local start_row = item.node.start_row
                self.marks:add(self.config, 'virtual_lines', start_row, 0, {
                    virt_lines = { virtual_line },
                    virt_lines_above = above,
                })
            end
        end
    end

    table_border(1, true, { border[1], border[2], border[3] })
    if #rows > 1 then
        table_border(#rows, false, { border[7], border[8], border[9] })
    end
end

return Render
