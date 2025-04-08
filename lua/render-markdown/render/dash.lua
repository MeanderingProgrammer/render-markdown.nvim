local Base = require('render-markdown.render.base')

---@class render.md.render.Dash: render.md.Renderer
---@field private info render.md.dash.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.dash
    if self.context:skip(self.info) then
        return false
    end
    return true
end

function Render:render()
    local width = self.info.width
    width = type(width) == 'number' and self.context:percent(width, 0)
        or vim.o.columns
    local margin = self.context:percent(self.info.left_margin, width)

    local line = self:append({}, margin)
    self:append(line, self.info.icon:rep(width), self.info.highlight)

    local start_row, end_row = self.node.start_row, self.node.end_row - 1
    self.marks:add('dash', start_row, 0, {
        virt_text = line,
        virt_text_pos = 'overlay',
    })
    if end_row > start_row then
        self.marks:add('dash', end_row, 0, {
            virt_text = line,
            virt_text_pos = 'overlay',
        })
    end
end

return Render
