local context = require('render-markdown.context')
local str = require('render-markdown.str')
local ts = require('render-markdown.ts')

---@class render.md.parser.CodeBlock
local M = {}

---@class render.md.parsed.CodeBlock
---@field col integer
---@field start_row integer
---@field end_row integer
---@field leading_spaces integer
---@field longest_line integer
---@field width integer
---@field code_info? render.md.NodeInfo
---@field language_info? render.md.NodeInfo
---@field language? string
---@field start_delim? render.md.NodeInfo
---@field end_delim? render.md.NodeInfo

---@param config render.md.Code
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.parsed.CodeBlock?
function M.parse(config, buf, info)
    -- Do not attempt to render single line code block
    if info.end_row - info.start_row <= 1 then
        return nil
    end
    local code_info = ts.child(buf, info, 'info_string', info.start_row)
    local language_info = ts.child(buf, code_info, 'language', info.start_row)
    local longest_line, width = M.get_width(config, buf, info)
    ---@type render.md.parsed.CodeBlock
    return {
        col = info.start_col,
        start_row = info.start_row,
        end_row = info.end_row,
        leading_spaces = str.leading_spaces(info.text),
        longest_line = longest_line,
        width = width,
        code_info = code_info,
        language_info = language_info,
        language = (language_info or {}).text,
        start_delim = ts.child(buf, info, 'fenced_code_block_delimiter', info.start_row),
        end_delim = ts.child(buf, info, 'fenced_code_block_delimiter', info.end_row - 1),
    }
end

---@private
---@param config render.md.Code
---@param buf integer
---@param info render.md.NodeInfo
---@return integer, integer
function M.get_width(config, buf, info)
    local lines = vim.api.nvim_buf_get_lines(buf, info.start_row, info.end_row, false)
    local code_width = vim.fn.max(vim.tbl_map(str.width, lines))
    local longest_line = config.left_pad + code_width + config.right_pad
    if config.width == 'block' then
        return longest_line, longest_line
    else
        return longest_line, context.get(buf):get_width()
    end
end

return M
