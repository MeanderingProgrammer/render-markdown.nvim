local Base = require('render-markdown.render.base')

---@class render.md.render.HtmlComment: render.md.Renderer
---@field private comment render.md.HtmlComment
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.comment = self.config.html.comment
    if not self.comment.conceal then
        return false
    end
    return true
end

function Render:render()
    self.marks:add_over(true, self.node, {
        conceal = '',
    })
    if self.comment.text ~= nil then
        self.marks:add_over(true, self.node, {
            virt_text = { { self.comment.text, self.comment.highlight } },
            virt_text_pos = 'inline',
        })
    end
end

return Render
