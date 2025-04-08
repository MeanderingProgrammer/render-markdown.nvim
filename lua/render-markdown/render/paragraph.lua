local Base = require('render-markdown.render.base')

---@class render.md.render.Paragraph: render.md.Renderer
---@field private info render.md.paragraph.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.paragraph
    if self.context:skip(self.info) then
        return false
    end
    if self.info.left_margin <= 0 then
        return false
    end
    return true
end

function Render:render()
    local width = vim.fn.max(self.node:widths())
    width = math.max(width, self.info.min_width)
    local margin = self.context:percent(self.info.left_margin, width)
    local line = self:append({}, margin)
    if #line == 0 then
        return
    end
    for row = self.node.start_row, self.node.end_row - 1 do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = line,
            virt_text_pos = 'inline',
        })
    end
end

return Render
