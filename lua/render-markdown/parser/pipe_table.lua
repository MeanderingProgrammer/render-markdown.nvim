local NodeInfo = require('render-markdown.node_info')
local logger = require('render-markdown.logger')
local str = require('render-markdown.str')

---@alias render.md.parsed.table.Alignment 'left'|'right'|'center'|'default'

---@class render.md.parsed.table.DelimColumn
---@field width integer
---@field alignment render.md.parsed.table.Alignment

---@class render.md.parsed.table.DelimRow
---@field info render.md.NodeInfo
---@field columns render.md.parsed.table.DelimColumn[]

---@class render.md.parsed.table.Column
---@field info render.md.NodeInfo
---@field width integer

---@class render.md.parsed.table.Row
---@field info render.md.NodeInfo
---@field pipes render.md.NodeInfo[]
---@field columns render.md.parsed.table.Column[]

---@class render.md.parsed.PipeTable
---@field info render.md.NodeInfo
---@field delim render.md.parsed.table.DelimRow
---@field rows render.md.parsed.table.Row[]

---@class render.md.parser.PipeTable
local M = {}

---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.parsed.PipeTable?
function M.parse(context, info)
    if info:has_error() then
        return nil
    end

    ---@type render.md.parsed.table.DelimRow?
    local delim = nil
    ---@type render.md.NodeInfo[]
    local table_rows = {}
    info:for_each_child(function(row)
        if row.type == 'pipe_table_delimiter_row' then
            delim = M.parse_delim(row)
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

    ---@type render.md.parsed.table.Row[]
    local rows = {}
    NodeInfo.sort_inplace(table_rows)
    for _, table_row in ipairs(table_rows) do
        local row = M.parse_row(context, table_row, #delim.columns)
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

    ---@type render.md.parsed.PipeTable
    return { info = info, delim = delim, rows = rows }
end

---@private
---@param info render.md.NodeInfo
---@return render.md.parsed.table.DelimRow?
function M.parse_delim(info)
    local row_data = M.parse_row_data(info, 'pipe_table_delimiter_cell')
    if row_data == nil then
        return nil
    end

    local pipes = row_data.pipes
    local cells = row_data.cells

    ---@type render.md.parsed.table.DelimColumn[]
    local columns = {}
    for i = 1, #cells do
        local cell = cells[i]
        local width = pipes[i + 1].start_col - pipes[i].end_col
        if width < 0 then
            return {}
        end
        ---@type render.md.parsed.table.DelimColumn
        local column = { width = width, alignment = M.parse_alignment(cell) }
        table.insert(columns, column)
    end
    ---@type render.md.parsed.table.DelimRow
    return { info = info, columns = columns }
end

---@private
---@param cell render.md.NodeInfo
---@return render.md.parsed.table.Alignment
function M.parse_alignment(cell)
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
---@return render.md.parsed.table.Row?
function M.parse_row(context, info, num_columns)
    local row_data = M.parse_row_data(info, 'pipe_table_cell')
    if row_data == nil then
        return nil
    end

    local pipes = row_data.pipes
    local cells = row_data.cells
    if #cells ~= num_columns then
        return nil
    end

    ---@type render.md.parsed.table.Column[]
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
        ---@type render.md.parsed.table.Column
        local column = { info = cell, width = width }
        table.insert(columns, column)
    end

    ---@type render.md.parsed.table.Row
    return { info = info, pipes = pipes, columns = columns }
end

---@private
---@param info render.md.NodeInfo
---@param cell_type string
---@return { pipes: render.md.NodeInfo[], cells: render.md.NodeInfo[] }?
function M.parse_row_data(info, cell_type)
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

return M
