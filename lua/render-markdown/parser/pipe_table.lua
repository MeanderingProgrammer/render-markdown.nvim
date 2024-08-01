local logger = require('render-markdown.logger')
local ts = require('render-markdown.ts')

---@class render.md.parser.PipeTable
local M = {}

---@class render.md.parsed.TableColumn
---@field width integer
---@field alignment 'left'|'right'|'center'|'default'

---@class render.md.parsed.PipeTable
---@field head render.md.NodeInfo
---@field delim render.md.NodeInfo
---@field columns render.md.parsed.TableColumn[]
---@field rows render.md.NodeInfo[]

---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.parsed.PipeTable?
function M.parse(buf, info)
    local head = nil
    local delim = nil
    local pipes = {}
    local cells = {}
    local rows = {}
    for row_node in info.node:iter_children() do
        local row = ts.info(row_node, buf)
        if row.type == 'pipe_table_header' then
            head = row
        elseif row.type == 'pipe_table_delimiter_row' then
            delim = row
            for cell_node in row.node:iter_children() do
                local cell = ts.info(cell_node, buf)
                if cell.type == '|' then
                    table.insert(pipes, cell)
                elseif cell.type == 'pipe_table_delimiter_cell' then
                    table.insert(cells, cell)
                else
                    logger.unhandled_type('markdown', 'delim cell', cell.type)
                end
            end
        elseif row.type == 'pipe_table_row' then
            table.insert(rows, row)
        else
            logger.unhandled_type('markdown', 'row', row.type)
        end
    end
    -- Check for empty heading / delimiter
    if head == nil or delim == nil then
        return nil
    end
    local columns = M.parse_columns(buf, pipes, cells)
    -- Check for missing row information
    if #rows == 0 then
        return nil
    end
    ts.sort_inplace(rows)
    ---@type render.md.parsed.PipeTable
    return { head = head, delim = delim, columns = columns, rows = rows }
end

---@private
---@param buf integer
---@param pipes render.md.NodeInfo[]
---@param cells render.md.NodeInfo[]
---@return render.md.parsed.TableColumn[]
function M.parse_columns(buf, pipes, cells)
    -- Check for missing column information
    if #pipes == 0 or #cells == 0 then
        return {}
    end
    -- Check for mismatch in column fence posts
    if #pipes ~= #cells + 1 then
        return {}
    end
    ts.sort_inplace(pipes)
    ts.sort_inplace(cells)
    local columns = {}
    for i = 1, #cells do
        local width = pipes[i + 1].start_col - pipes[i].end_col
        if width < 0 then
            return {}
        end
        ---@type render.md.parsed.TableColumn
        local column = { width = width, alignment = M.parse_alignment(buf, cells[i]) }
        table.insert(columns, column)
    end
    return columns
end

---@private
---@param buf integer
---@param cell render.md.NodeInfo
---@return 'left'|'right'|'center'|'default'
function M.parse_alignment(buf, cell)
    local align_left = ts.child(buf, cell, 'pipe_table_align_left') ~= nil
    local align_right = ts.child(buf, cell, 'pipe_table_align_right') ~= nil
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

return M
