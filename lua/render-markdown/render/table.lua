local NodeInfo = require('render-markdown.core.node_info')
local logger = require('render-markdown.core.logger')
local str = require('render-markdown.core.str')
local util = require('render-markdown.render.util')

---@class render.md.table.Column
---@field row integer
---@field col integer
---@field width integer

---@class render.md.table.Row
---@field info render.md.NodeInfo
---@field pipes render.md.NodeInfo[]
---@field columns render.md.table.Column[]

---@alias render.md.table.Alignment 'left'|'right'|'center'|'default'

---@class render.md.table.DelimColumn
---@field width integer
---@field alignment render.md.table.Alignment

---@class render.md.table.DelimRow
---@field info render.md.NodeInfo
---@field columns render.md.table.DelimColumn[]

---@class render.md.data.Table
---@field delim render.md.table.DelimRow
---@field rows render.md.table.Row[]

---@class render.md.render.Table: render.md.Renderer
---@field private table render.md.PipeTable
---@field private data render.md.data.Table
local Render = {}
Render.__index = Render

---@param marks render.md.Marks
---@param config render.md.BufferConfig
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Render.new(marks, config, context, info)
    return setmetatable({ marks = marks, config = config, context = context, info = info }, Render)
end

---@return boolean
function Render:setup()
    self.table = self.config.pipe_table
    if not self.table.enabled or self.table.style == 'none' then
        return false
    end
    if self.info:has_error() then
        return false
    end

    local delim, table_rows = nil, {}
    self.info:for_each_child(function(row)
        if row.type == 'pipe_table_delimiter_row' then
            delim = Render.parse_delim(row)
        elseif self.context:contains_info(row) then
            if vim.tbl_contains({ 'pipe_table_header', 'pipe_table_row' }, row.type) then
                table.insert(table_rows, row)
            else
                logger.unhandled_type('markdown', 'row', row.type)
            end
        end
    end)
    -- Ensure delimiter and rows exist for table
    if delim == nil or #table_rows == 0 then
        return false
    end

    local rows = {}
    for _, table_row in ipairs(NodeInfo.sort_inplace(table_rows)) do
        local row = self:parse_row(table_row, #delim.columns)
        if row ~= nil then
            table.insert(rows, row)
        end
    end
    -- Store the max width information in the delimiter
    for _, row in ipairs(rows) do
        for i, r_column in ipairs(row.columns) do
            local d_column = delim.columns[i]
            d_column.width = math.max(d_column.width, r_column.width)
        end
    end

    self.data = { delim = delim, rows = rows }

    return true
end

---@private
---@param row render.md.NodeInfo
---@return render.md.table.DelimRow?
function Render.parse_delim(row)
    local pipes, cells = Render.parse_row_data(row, 'pipe_table_delimiter_cell')
    if pipes == nil or cells == nil then
        return nil
    end
    local columns = {}
    for i = 1, #cells do
        local cell, width = cells[i], pipes[i + 1].start_col - pipes[i].end_col
        if width < 0 then
            return nil
        end
        table.insert(columns, { width = width, alignment = Render.alignment(cell) })
    end
    return { info = row, columns = columns }
end

---@param cell render.md.NodeInfo
---@return render.md.table.Alignment
function Render.alignment(cell)
    local align_left = cell:child('pipe_table_align_left') ~= nil
    local align_right = cell:child('pipe_table_align_right') ~= nil
    if align_left and align_right then
        return 'center'
    elseif align_left then
        return 'left'
    elseif align_right then
        return 'right'
    else
        return 'default'
    end
end

---@private
---@param row render.md.NodeInfo
---@param num_columns integer
---@return render.md.table.Row?
function Render:parse_row(row, num_columns)
    local pipes, cells = Render.parse_row_data(row, 'pipe_table_cell')
    if pipes == nil or cells == nil or #cells ~= num_columns then
        return nil
    end
    local columns = {}
    for i = 1, #cells do
        local cell, width = cells[i], pipes[i + 1].start_col - pipes[i].end_col
        -- Account for double width glyphs by replacing cell spacing with text width
        width = width - (cell.end_col - cell.start_col) + str.width(cell.text)
        -- Remove concealed and add inlined text
        width = width - self.context:concealed(cell) + self.context:get_offset(cell)
        if width < 0 then
            return nil
        end
        ---@type render.md.table.Column
        local column = { row = cell.start_row, col = cell.end_col, width = width }
        table.insert(columns, column)
    end
    return { info = row, pipes = pipes, columns = columns }
end

---@private
---@param row render.md.NodeInfo
---@param cell_type string
---@return render.md.NodeInfo[]?, render.md.NodeInfo[]?
function Render.parse_row_data(row, cell_type)
    local pipes, cells = {}, {}
    row:for_each_child(function(cell)
        if cell.type == '|' then
            table.insert(pipes, cell)
        elseif cell.type == cell_type then
            table.insert(cells, cell)
        else
            logger.unhandled_type('markdown', 'cell', cell.type)
        end
    end)
    if #pipes == 0 or #cells == 0 or #pipes ~= #cells + 1 then
        return nil, nil
    end
    return NodeInfo.sort_inplace(pipes), NodeInfo.sort_inplace(cells)
end

function Render:render()
    self:delimiter()
    for _, row in ipairs(self.data.rows) do
        self:row(row)
    end
    if self.table.style == 'full' then
        self:full()
    end
end

---@private
function Render:delimiter()
    local delim, border = self.data.delim, self.table.border

    local sections = vim.tbl_map(function(column)
        local indicator = self.table.alignment_indicator
        -- If column is small there's no good place to put the alignment indicator
        -- Alignment indicator must be exactly one character wide
        -- Do not put an indicator for default alignment
        if column.width < 4 or str.width(indicator) ~= 1 or column.alignment == 'default' then
            return border[11]:rep(column.width)
        end
        -- Handle the various alignmnet possibilities
        local left = border[11]:rep(math.floor(column.width / 2))
        local right = border[11]:rep(math.ceil(column.width / 2) - 1)
        if column.alignment == 'left' then
            return indicator .. left .. right
        elseif column.alignment == 'right' then
            return left .. right .. indicator
        else
            return left .. indicator .. right
        end
    end, delim.columns)

    local virt_text = {}
    local leading_spaces = str.leading_spaces(delim.info.text)
    if leading_spaces > 0 then
        table.insert(virt_text, { str.spaces(leading_spaces), 'Normal' })
    end
    table.insert(virt_text, { border[4] .. table.concat(sections, border[5]) .. border[6], self.table.head })

    self.marks:add(true, delim.info.start_row, delim.info.start_col, {
        end_row = delim.info.end_row,
        end_col = delim.info.end_col,
        virt_text = virt_text,
        virt_text_pos = 'overlay',
    })
end

---@private
---@param row render.md.table.Row
function Render:row(row)
    local delim, border = self.data.delim, self.table.border
    local highlight = row.info.type == 'pipe_table_header' and self.table.head or self.table.row

    if self.table.cell == 'padded' then
        for _, pipe in ipairs(row.pipes) do
            self.marks:add(true, pipe.start_row, pipe.start_col, {
                end_row = pipe.end_row,
                end_col = pipe.end_col,
                virt_text = { { border[10], highlight } },
                virt_text_pos = 'overlay',
            })
        end
        for i, column in ipairs(row.columns) do
            local offset = delim.columns[i].width - column.width
            if offset > 0 then
                -- Use low priority to include pipe marks in padding
                self.marks:add(true, column.row, column.col, {
                    priority = 0,
                    virt_text = { { str.spaces(offset), self.table.filler } },
                    virt_text_pos = 'inline',
                })
            end
        end
    elseif self.table.cell == 'raw' then
        for _, pipe in ipairs(row.pipes) do
            self.marks:add(true, pipe.start_row, pipe.start_col, {
                end_row = pipe.end_row,
                end_col = pipe.end_col,
                virt_text = { { border[10], highlight } },
                virt_text_pos = 'overlay',
            })
        end
    elseif self.table.cell == 'overlay' then
        self.marks:add(true, row.info.start_row, row.info.start_col, {
            end_row = row.info.end_row,
            end_col = row.info.end_col,
            virt_text = { { row.info.text:gsub('|', border[10]), highlight } },
            virt_text_pos = 'overlay',
        })
    end
end

---@private
function Render:full()
    local delim, rows, border = self.data.delim, self.data.rows, self.table.border

    ---@param row render.md.table.Row
    ---@return boolean
    local function width_equal(row)
        if self.table.cell == 'padded' then
            -- Assume table was padded to match
            return true
        elseif self.table.cell == 'raw' then
            -- Want the computed widths to match
            for i, column in ipairs(row.columns) do
                if delim.columns[i].width ~= column.width then
                    return false
                end
            end
            return true
        elseif self.table.cell == 'overlay' then
            -- Want the underlying text widths to match
            return str.width(delim.info.text) == str.width(row.info.text)
        else
            return false
        end
    end

    ---@param row render.md.table.Row
    ---@return integer
    local function get_spaces(row)
        return math.max(str.leading_spaces(row.info.text), row.info.start_col)
    end

    local first, last = rows[1], rows[#rows]
    if not width_equal(first) or not width_equal(last) then
        return
    end

    local spaces = get_spaces(first)
    if spaces ~= get_spaces(last) then
        return
    end

    local sections = vim.tbl_map(function(column)
        return border[11]:rep(column.width)
    end, delim.columns)

    ---@param info render.md.NodeInfo
    ---@param above boolean
    ---@param chars { [1]: string, [2]: string, [3]: string }
    local function table_border(info, above, chars)
        local line = spaces > 0 and { { str.spaces(spaces), 'Normal' } } or {}
        local highlight = above and self.table.head or self.table.row
        table.insert(line, { chars[1] .. table.concat(sections, chars[2]) .. chars[3], highlight })
        self.marks:add(false, info.start_row, info.start_col, {
            virt_lines_above = above,
            virt_lines = { util.indent_virt_line(self.config, self.info, line) },
        })
    end

    local last_info = #rows == 1 and delim.info or last.info
    table_border(first.info, true, { border[1], border[2], border[3] })
    table_border(last_info, false, { border[7], border[8], border[9] })
end

return Render
