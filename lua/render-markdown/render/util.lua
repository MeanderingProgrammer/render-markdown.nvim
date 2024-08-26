local colors = require('render-markdown.colors')
local state = require('render-markdown.state')
local str = require('render-markdown.core.str')

---@class render.md.Renderer
---@field protected buf integer
---@field protected marks render.md.Marks
---@field protected context render.md.Context
---@field render fun(self: render.md.Renderer, info: render.md.NodeInfo)

---@class render.md.render.Util
local M = {}

---@param buf integer
---@param marks render.md.Marks
---@param info render.md.NodeInfo
---@param text? string
---@param highlight string
function M.sign(buf, marks, info, text, highlight)
    local config = state.get_config(buf).sign
    if not config.enabled or text == nil then
        return
    end
    marks:add(false, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        sign_text = text,
        sign_hl_group = colors.combine(highlight, config.highlight),
    })
end

---@param buf integer
---@param info render.md.NodeInfo
---@param line { [1]: string, [2]: string }[]
---@return { [1]: string, [2]: string }[]
function M.indent_virt_line(buf, info, line)
    local config = state.get_config(buf).indent
    if not config.enabled then
        return line
    end
    local level = info:level() - 1
    if level <= 0 then
        return line
    end
    local indent_line = { str.spaces(config.per_level * level), 'Normal' }
    table.insert(line, 1, indent_line)
    return line
end

return M
