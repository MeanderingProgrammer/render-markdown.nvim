local str = require('render-markdown.str')

---@class render.md.parser.CodeBlock
local M = {}

---@class render.md.parsed.CodeBlock
---@field col integer
---@field start_row integer
---@field end_row integer
---@field leading_spaces integer
---@field empty_rows integer[]
---@field longest_line integer
---@field width integer
---@field code_info_hidden boolean
---@field language_info? render.md.NodeInfo
---@field language? string
---@field start_delim_hidden boolean
---@field end_delim_hidden boolean

---@param config render.md.Code
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.parsed.CodeBlock?
function M.parse(config, context, info)
    -- Do not attempt to render single line code block
    if info.end_row - info.start_row <= 1 then
        return nil
    end

    -- Account for language padding in first row
    local widths = vim.tbl_map(str.width, info:lines())
    widths[1] = widths[1] + config.language_pad
    local longest_line, width = M.get_width(config, context, widths)

    local code_info = info:child('info_string', info.start_row)
    local language_info = code_info ~= nil and code_info:child('language', info.start_row) or nil

    ---@type render.md.parsed.CodeBlock
    return {
        col = info.start_col,
        start_row = info.start_row,
        end_row = info.end_row,
        leading_spaces = str.leading_spaces(info.text),
        empty_rows = M.get_empty_rows(info.start_row, widths),
        longest_line = longest_line,
        width = width,
        code_info_hidden = context:hidden(code_info),
        language_info = language_info,
        language = (language_info or {}).text,
        start_delim_hidden = context:hidden(info:child('fenced_code_block_delimiter', info.start_row)),
        end_delim_hidden = context:hidden(info:child('fenced_code_block_delimiter', info.end_row - 1)),
    }
end

---@private
---@param start_row integer
---@param widths integer[]
---@return integer[]
function M.get_empty_rows(start_row, widths)
    local empty_rows = {}
    for row, width in ipairs(widths) do
        if width == 0 then
            table.insert(empty_rows, start_row + row - 1)
        end
    end
    return empty_rows
end

---@private
---@param config render.md.Code
---@param context render.md.Context
---@param widths integer[]
---@return integer, integer
function M.get_width(config, context, widths)
    local code_width = vim.fn.max(widths)
    local longest_line = config.left_pad + code_width + config.right_pad
    local width = math.max(longest_line, config.min_width)
    if config.width == 'block' then
        return width, width
    else
        return width, context:get_width()
    end
end

return M
