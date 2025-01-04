local Base = require('render-markdown.render.base')
local Iter = require('render-markdown.lib.iter')
local Str = require('render-markdown.lib.str')

---@class render.md.render.Paragraph: render.md.Renderer
---@field private paragraph render.md.Paragraph
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.paragraph = self.config.paragraph
    if self.context:skip(self.paragraph) then
        return false
    end
    if self.paragraph.left_margin <= 0 then
        return false
    end
    return true
end

function Render:render()
    local width = vim.fn.max(Iter.list.map(self.node:lines(), Str.width))
    width = math.max(width, self.paragraph.min_width)
    local margin = self.context:resolve_offset(self.paragraph.left_margin, width)
    if margin <= 0 then
        return
    end

    local virt_text = { self:padding_text(margin) }
    for row = self.node.start_row, self.node.end_row - 1 do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = virt_text,
            virt_text_pos = 'inline',
        })
    end
end

return Render
