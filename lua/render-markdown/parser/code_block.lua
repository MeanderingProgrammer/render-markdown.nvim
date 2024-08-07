local context = require('render-markdown.context')
local str = require('render-markdown.str')

---@class render.md.parser.CodeBlock
local M = {}

---@class render.md.parsed.CodeBlock
---@field col integer
---@field start_row integer
---@field end_row integer
---@field leading_spaces integer
---@field longest_line integer
---@field width integer
---@field code_info_hidden boolean
---@field language_info? render.md.NodeInfo
---@field language? string
---@field start_delim_hidden boolean
---@field end_delim_hidden boolean

---@param config render.md.Code
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.parsed.CodeBlock?
function M.parse(config, buf, info)
    -- Do not attempt to render single line code block
    if info.end_row - info.start_row <= 1 then
        return nil
    end
    local code_info = info:child('info_string', info.start_row)
    local language_info = nil
    if code_info ~= nil then
        language_info = code_info:child('language', info.start_row)
    end
    local longest_line, width = M.get_width(config, buf, info)
    ---@type render.md.parsed.CodeBlock
    return {
        col = info.start_col,
        start_row = info.start_row,
        end_row = info.end_row,
        leading_spaces = str.leading_spaces(info.text),
        longest_line = longest_line,
        width = width,
        code_info_hidden = M.hidden(code_info),
        language_info = language_info,
        language = (language_info or {}).text,
        start_delim_hidden = M.hidden(info:child('fenced_code_block_delimiter', info.start_row)),
        end_delim_hidden = M.hidden(info:child('fenced_code_block_delimiter', info.end_row - 1)),
    }
end

---@private
---@param config render.md.Code
---@param buf integer
---@param info render.md.NodeInfo
---@return integer, integer
function M.get_width(config, buf, info)
    local lines = info:lines()
    local code_width = vim.fn.max(vim.tbl_map(str.width, lines))
    local longest_line = config.left_pad + code_width + config.right_pad
    local width = math.max(longest_line, config.min_width)
    if config.width == 'block' then
        return width, width
    else
        return width, context.get(buf):get_width()
    end
end

---@private
---@param info? render.md.NodeInfo
---@return boolean
function M.hidden(info)
    if info == nil then
        return true
    end
    return info:hidden()
end

return M
