local NodeInfo = require('render-markdown.node_info')
local logger = require('render-markdown.logger')
local str = require('render-markdown.str')
local util = require('render-markdown.render.util')

---@alias render.md.table.Alignment 'left'|'right'|'center'|'default'

---@class render.md.table.DelimColumn
---@field width integer
---@field alignment render.md.table.Alignment

---@class render.md.table.DelimRow
---@field info render.md.NodeInfo
---@field columns render.md.table.DelimColumn[]

---@class render.md.table.Column
---@field info render.md.NodeInfo
---@field width integer

---@class render.md.table.Row
---@field info render.md.NodeInfo
---@field pipes render.md.NodeInfo[]
---@field columns render.md.table.Column[]

---@class render.md.table.Table
---@field info render.md.NodeInfo
---@field delim render.md.table.DelimRow
---@field rows render.md.table.Row[]

---@class render.md.parser.Table
local Parser = {}

---@private
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.table.Table?
function Parser.parse(context, info)
    if info:has_error() then
        return nil
    end

    ---@type render.md.table.DelimRow?
    local delim = nil
    ---@type render.md.NodeInfo[]
    local table_rows = {}
    info:for_each_child(function(row)
        if row.type == 'pipe_table_delimiter_row' then
            delim = Parser.delim(row)
        elseif context:contains_info(row) then
            if row.type == 'pipe_table_header' or row.type == 'pipe_table_row' then
                table.insert(table_rows, row)
            else
                logger.unhandled_type('markdown', 'row', row.type)
            end
        end
    end)

    -- Ensure delimiter and rows exist for table
    if delim == nil or #table_rows == 0 then
        return nil
    end

    ---@type render.md.table.Row[]
    local rows = {}
    NodeInfo.sort_inplace(table_rows)
    for _, table_row in ipairs(table_rows) do
        local row = Parser.row(context, table_row, #delim.columns)
        if row ~= nil then
            table.insert(rows, row)
        end
    end

    -- Store the max width information in the delimiter
    for _, row in ipairs(rows) do
        for i, column in ipairs(row.columns) do
            local delim_column = delim.columns[i]
            delim_column.width = math.max(delim_column.width, column.width)
        end
    end

    ---@type render.md.table.Table
    return { info = info, delim = delim, rows = rows }
end

---@private
---@param info render.md.NodeInfo
---@return render.md.table.DelimRow?
function Parser.delim(info)
    local row_data = Parser.row_data(info, 'pipe_table_delimiter_cell')
    if row_data == nil then
        return nil
    end

    local pipes = row_data.pipes
    local cells = row_data.cells

    ---@type render.md.table.DelimColumn[]
    local columns = {}
    for i = 1, #cells do
        local cell = cells[i]
        local width = pipes[i + 1].start_col - pipes[i].end_col
        if width < 0 then
            return {}
        end
        ---@type render.md.table.DelimColumn
        local column = { width = width, alignment = Parser.alignment(cell) }
        table.insert(columns, column)
    end
    ---@type render.md.table.DelimRow
    return { info = info, columns = columns }
end

---@private
---@param cell render.md.NodeInfo
---@return render.md.table.Alignment
function Parser.alignment(cell)
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
---@param context render.md.Context
---@param info render.md.NodeInfo
---@param num_columns integer
---@return render.md.table.Row?
function Parser.row(context, info, num_columns)
    local row_data = Parser.row_data(info, 'pipe_table_cell')
    if row_data == nil then
        return nil
    end

    local pipes = row_data.pipes
    local cells = row_data.cells
    if #cells ~= num_columns then
        return nil
    end

    ---@type render.md.table.Column[]
    local columns = {}
    for i = 1, #cells do
        local cell = cells[i]
        local width = pipes[i + 1].start_col - pipes[i].end_col
        -- Account for double width glyphs by replacing cell spacing with text width
        width = width - (cell.end_col - cell.start_col) + str.width(cell.text)
        -- Remove concealed and add inlined text
        width = width - context:concealed(cell) + context:get_offset(cell)
        if width < 0 then
            return nil
        end
        ---@type render.md.table.Column
        local column = { info = cell, width = width }
        table.insert(columns, column)
    end

    ---@type render.md.table.Row
    return { info = info, pipes = pipes, columns = columns }
end

---@private
---@param info render.md.NodeInfo
---@param cell_type string
---@return { pipes: render.md.NodeInfo[], cells: render.md.NodeInfo[] }?
function Parser.row_data(info, cell_type)
    ---@type render.md.NodeInfo[]
    local pipes = {}
    ---@type render.md.NodeInfo[]
    local cells = {}
    info:for_each_child(function(cell)
        if cell.type == '|' then
            table.insert(pipes, cell)
        elseif cell.type == cell_type then
            table.insert(cells, cell)
        else
            logger.unhandled_type('markdown', 'cell', cell.type)
        end
    end)
    if #pipes == 0 or #cells == 0 or #pipes ~= #cells + 1 then
        return nil
    end
    NodeInfo.sort_inplace(pipes)
    NodeInfo.sort_inplace(cells)
    return { pipes = pipes, cells = cells }
end

---@class render.md.render.Table
---@field private buf integer
---@field private marks render.md.Marks
---@field private config render.md.PipeTable
---@field private context render.md.Context
local Render = {}
Render.__index = Render

---@param buf integer
---@param marks render.md.Marks
---@param config render.md.BufferConfig
---@param context render.md.Context
---@return render.md.render.Table
function Render.new(buf, marks, config, context)
    local self = setmetatable({}, Render)
    self.buf = buf
    self.marks = marks
    self.config = config.pipe_table
    self.context = context
    return self
end

---@param info render.md.NodeInfo
function Render:render(info)
    if not self.config.enabled or self.config.style == 'none' then
        return
    end
    local tbl = Parser.parse(self.context, info)
    if tbl == nil then
        return
    end

    self:delimiter(tbl.delim)
    for _, row in ipairs(tbl.rows) do
        self:row(tbl.delim, row)
    end
    if self.config.style == 'full' then
        self:full(tbl)
    end
end

---@private
---@param delim render.md.table.DelimRow
function Render:delimiter(delim)
    local indicator = self.config.alignment_indicator
    local border = self.config.border

    local sections = vim.tbl_map(function(column)
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
    table.insert(virt_text, { border[4] .. table.concat(sections, border[5]) .. border[6], self.config.head })

    self.marks:add(true, delim.info.start_row, delim.info.start_col, {
        end_row = delim.info.end_row,
        end_col = delim.info.end_col,
        virt_text = virt_text,
        virt_text_pos = 'overlay',
    })
end

---@private
---@param delim render.md.table.DelimRow
---@param row render.md.table.Row
function Render:row(delim, row)
    local highlight = row.info.type == 'pipe_table_header' and self.config.head or self.config.row
    if self.config.cell == 'padded' then
        for _, pipe in ipairs(row.pipes) do
            self.marks:add(true, pipe.start_row, pipe.start_col, {
                end_row = pipe.end_row,
                end_col = pipe.end_col,
                virt_text = { { self.config.border[10], highlight } },
                virt_text_pos = 'overlay',
            })
        end
        for i, column in ipairs(row.columns) do
            local offset = delim.columns[i].width - column.width
            if offset > 0 then
                -- Use low priority to include pipe marks in padding
                self.marks:add(true, column.info.start_row, column.info.end_col, {
                    priority = 0,
                    virt_text = { { str.spaces(offset), self.config.filler } },
                    virt_text_pos = 'inline',
                })
            end
        end
    elseif self.config.cell == 'raw' then
        for _, pipe in ipairs(row.pipes) do
            self.marks:add(true, pipe.start_row, pipe.start_col, {
                end_row = pipe.end_row,
                end_col = pipe.end_col,
                virt_text = { { self.config.border[10], highlight } },
                virt_text_pos = 'overlay',
            })
        end
    elseif self.config.cell == 'overlay' then
        self.marks:add(true, row.info.start_row, row.info.start_col, {
            end_row = row.info.end_row,
            end_col = row.info.end_col,
            virt_text = { { row.info.text:gsub('|', self.config.border[10]), highlight } },
            virt_text_pos = 'overlay',
        })
    end
end

---@private
---@param tbl render.md.table.Table
function Render:full(tbl)
    local border = self.config.border

    ---@param row render.md.table.Row
    ---@param delim render.md.table.DelimRow
    ---@return boolean
    local function width_equal(row, delim)
        if self.config.cell == 'padded' then
            -- Assume table was padded to match
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

    local delim = tbl.delim
    local first = tbl.rows[1]
    local last = tbl.rows[#tbl.rows]
    if not width_equal(first, delim) or not width_equal(last, delim) then
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
        local highlight = above and self.config.head or self.config.row
        table.insert(line, { chars[1] .. table.concat(sections, chars[2]) .. chars[3], highlight })
        self.marks:add(false, info.start_row, info.start_col, {
            virt_lines_above = above,
            virt_lines = { util.indent_virt_line(self.buf, tbl.info, line) },
        })
    end

    local last_info = #tbl.rows == 1 and delim.info or last.info
    table_border(first.info, true, { border[1], border[2], border[3] })
    table_border(last_info, false, { border[7], border[8], border[9] })
end

return Render
