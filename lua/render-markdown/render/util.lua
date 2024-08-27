local colors = require('render-markdown.colors')
local str = require('render-markdown.core.str')

---@class render.md.Renderer
---@field protected marks render.md.Marks
---@field protected config render.md.BufferConfig
---@field protected context render.md.Context
---@field protected info render.md.NodeInfo
---@field new fun(marks: render.md.Marks, config: render.md.BufferConfig, context: render.md.Context, info: render.md.NodeInfo): render.md.Renderer
---@field setup fun(self: render.md.Renderer): boolean
---@field render fun(self: render.md.Renderer)

---@class render.md.render.Util
local M = {}

---@param config render.md.BufferConfig
---@param marks render.md.Marks
---@param info render.md.NodeInfo
---@param text? string
---@param highlight string
function M.sign(config, marks, info, text, highlight)
    if not config.sign.enabled or text == nil then
        return
    end
    marks:add(false, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        sign_text = text,
        sign_hl_group = colors.combine(highlight, config.sign.highlight),
    })
end

---@param config render.md.BufferConfig
---@param info render.md.NodeInfo
---@param line { [1]: string, [2]: string }[]
---@return { [1]: string, [2]: string }[]
function M.indent_virt_line(config, info, line)
    if not config.indent.enabled then
        return line
    end
    local level = info:level() - 1
    if level <= 0 then
        return line
    end
    local indent_line = { str.spaces(config.indent.per_level * level), 'Normal' }
    table.insert(line, 1, indent_line)
    return line
end

return M
