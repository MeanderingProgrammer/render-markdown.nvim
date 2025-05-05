local Base = require('render-markdown.render.base')
local Iter = require('render-markdown.lib.iter')
local Str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')

---@class render.md.table.Data
---@field delim render.md.table.DelimRow
---@field rows render.md.table.Row[]

---@class render.md.table.DelimRow
---@field node render.md.Node
---@field columns render.md.table.DelimColumn[]

---@class render.md.table.DelimColumn
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
---@field columns render.md.table.Column[]

---@class render.md.table.Column
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

    local delim = nil ---@type render.md.table.DelimRow?
    local table_rows = {} ---@type render.md.Node[]
    self.node:for_each_child(function(row)
        if row.type == 'pipe_table_delimiter_row' then
            delim = self:parse_delim(row)
        elseif self.context.view:overlaps(row:get()) then
            local row_types = { 'pipe_table_header', 'pipe_table_row' }
            if vim.tbl_contains(row_types, row.type) then
                table_rows[#table_rows + 1] = row
            else
                log.unhandled_type('markdown', 'row', row.type)
            end
        end
    end)

    -- Ensure delimiter and rows exist for table
    if not delim or #table_rows == 0 then
        return false
    end

    local rows = {} ---@type render.md.table.Row[]
    table.sort(table_rows)
    for _, table_row in ipairs(table_rows) do
        local row = self:parse_row(table_row, #delim.columns)
        if row then
            rows[#rows + 1] = row
        end
    end

    -- Double check rows still exist after parsing
    if #rows == 0 then
        return false
    end

    -- Store the max width in the delimiter
    for _, row in ipairs(rows) do
        for i, column in ipairs(row.columns) do
            local width = column.width
            local space_available = column.space.left
                + column.space.right
                - (2 * self.config.padding)
            -- If we don't have enough space for padding add it to the width
            if space_available < 0 then
                width = width - space_available
            end
            if self.config.cell == 'trimmed' then
                width = width - math.max(space_available, 0)
            end
            local delim_column = delim.columns[i]
            delim_column.width = math.max(delim_column.width, width)
        end
    end

    self.data = { delim = delim, rows = rows }

    return true
end

---@private
---@param row render.md.Node
---@return render.md.table.DelimRow?
function Render:parse_delim(row)
    local pipes, cells = Render.parse_row_data(row, 'pipe_table_delimiter_cell')
    if not pipes or not cells then
        return nil
    end
    local columns = {} ---@type render.md.table.DelimColumn[]
    for i, cell in ipairs(cells) do
        local width = pipes[i + 1].start_col - pipes[i].end_col
        if width < 0 then
            return nil
        end
        if self.config.cell == 'padded' then
            width = math.max(width, self.config.min_width)
        elseif self.config.cell == 'trimmed' then
            width = self.config.min_width
        end
        columns[#columns + 1] = {
            width = width,
            alignment = Render.alignment(cell),
        }
    end
    ---@type render.md.table.DelimRow
    return { node = row, columns = columns }
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
---@param row render.md.Node
---@param num_columns integer
---@return render.md.table.Row?
function Render:parse_row(row, num_columns)
    local pipes, cells = Render.parse_row_data(row, 'pipe_table_cell')
    if not pipes or not cells or #cells ~= num_columns then
        return nil
    end
    local columns = {} ---@type render.md.table.Column[]
    for i, cell in ipairs(cells) do
        local start_col, end_col = pipes[i].end_col, pipes[i + 1].start_col
        -- Account for double width glyphs by replacing cell range with its width
        local width = end_col - start_col
        width = width
            - (cell.end_col - cell.start_col)
            + self.context:width(cell)
        if width < 0 then
            return nil
        end
        columns[#columns + 1] = {
            row = cell.start_row,
            start_col = cell.start_col,
            end_col = cell.end_col,
            width = width,
            space = {
                -- Left space comes from the gap between the node start and the pipe start
                left = math.max(cell.start_col - start_col, 0),
                -- Right space is attached to the node itself
                right = math.max(Str.spaces('end', cell.text), 0),
            },
        }
    end
    ---@type render.md.table.Row
    return { node = row, pipes = pipes, columns = columns }
end

---@private
---@param row render.md.Node
---@param cell_type string
---@return render.md.Node[]?, render.md.Node[]?
function Render.parse_row_data(row, cell_type)
    local pipes, cells = {}, {}
    row:for_each_child(function(cell)
        if cell.type == '|' then
            pipes[#pipes + 1] = cell
        elseif cell.type == cell_type then
            cells[#cells + 1] = cell
        else
            log.unhandled_type('markdown', 'cell', cell.type)
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
        self:full()
    end
end

---@private
function Render:delimiter()
    local delim, border = self.data.delim, self.config.border

    local indicator, icon = self.config.alignment_indicator, border[11]
    local parts = Iter.list.map(delim.columns, function(column)
        -- If column is small there's no good place to put the alignment indicator
        -- Alignment indicator must be exactly one character wide
        -- Do not put an indicator for default alignment
        if
            column.width < 3
            or Str.width(indicator) ~= 1
            or column.alignment == Alignment.default
        then
            return icon:rep(column.width)
        end
        if column.alignment == Alignment.left then
            return indicator .. icon:rep(column.width - 1)
        elseif column.alignment == Alignment.right then
            return icon:rep(column.width - 1) .. indicator
        else
            return indicator .. icon:rep(column.width - 2) .. indicator
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
    local delim, border = self.data.delim, self.config.border
    local highlight = row.node.type == 'pipe_table_header' and self.config.head
        or self.config.row

    if vim.tbl_contains({ 'trimmed', 'padded', 'raw' }, self.config.cell) then
        for _, pipe in ipairs(row.pipes) do
            self.marks:over('table_border', pipe, {
                virt_text = { { border[10], highlight } },
                virt_text_pos = 'overlay',
            })
        end
    end

    if vim.tbl_contains({ 'trimmed', 'padded' }, self.config.cell) then
        for i, column in ipairs(row.columns) do
            local delim_column = delim.columns[i]
            local filler = delim_column.width - column.width
            if not self.context.conceal:enabled() then
                -- Without concealing it is impossible to do full alignment
                self:shift(column, 'right', filler)
            elseif delim_column.alignment == Alignment.center then
                local shift = math.floor(
                    (filler + column.space.right - column.space.left) / 2
                )
                self:shift(column, 'left', shift)
                self:shift(column, 'right', filler - shift)
            elseif delim_column.alignment == Alignment.right then
                local shift = column.space.right - self.config.padding
                self:shift(column, 'left', filler + shift)
                self:shift(column, 'right', -shift)
            else
                local shift = column.space.left - self.config.padding
                self:shift(column, 'left', -shift)
                self:shift(column, 'right', filler + shift)
            end
        end
    elseif self.config.cell == 'overlay' then
        self.marks:over('table_border', row.node, {
            virt_text = { { row.node.text:gsub('|', border[10]), highlight } },
            virt_text_pos = 'overlay',
        })
    end
end

---Use low priority to include pipe marks
---@private
---@param column render.md.table.Column
---@param side 'left'|'right'
---@param amount integer
function Render:shift(column, side, amount)
    local col = side == 'left' and column.start_col or column.end_col
    if amount > 0 then
        self.marks:add(true, column.row, col, {
            priority = 0,
            virt_text = self:line():pad(amount, self.config.filler):get(),
            virt_text_pos = 'inline',
        })
    elseif amount < 0 then
        amount = amount - self.context.conceal:width('')
        self.marks:add(true, column.row, col + amount, {
            priority = 0,
            end_col = col,
            conceal = '',
        })
    end
end

---@private
function Render:full()
    local delim = self.data.delim
    local rows = self.data.rows
    local border = self.config.border

    ---@param row render.md.table.Row
    ---@return boolean
    local function width_equal(row)
        if vim.tbl_contains({ 'trimmed', 'padded' }, self.config.cell) then
            -- Assume table was trimmed or padded to match
            return true
        elseif self.config.cell == 'raw' then
            -- Want the computed widths to match
            for i, column in ipairs(row.columns) do
                if delim.columns[i].width ~= column.width then
                    return false
                end
            end
            return true
        elseif self.config.cell == 'overlay' then
            -- Want the underlying text widths to match
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

    local sections = Iter.list.map(delim.columns, function(column)
        return border[11]:rep(column.width)
    end)

    ---@param node render.md.Node
    ---@param above boolean
    ---@param chars { [1]: string, [2]: string, [3]: string }
    local function table_border(node, above, chars)
        local text = chars[1] .. table.concat(sections, chars[2]) .. chars[3]
        local highlight = above and self.config.head or self.config.row
        local line = self:line():pad(spaces):text(text, highlight)
        self.marks:start(false, node, {
            virt_lines = { self:indent():line(true):extend(line):get() },
            virt_lines_above = above,
        })
    end

    table_border(first_node, true, { border[1], border[2], border[3] })
    if #rows > 1 then
        table_border(last_node, false, { border[7], border[8], border[9] })
    end
end

return Render
