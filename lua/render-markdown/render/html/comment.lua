local Base = require('render-markdown.render.base')

---@class render.md.render.html.Comment: render.md.Render
---@field private config render.md.html.comment.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.html.comment
    if not self.config.conceal then
        return false
    end
    return true
end

---@protected
function Render:run()
    self.marks:over(true, self.node, { conceal = '' })
    if self.config.text then
        self.marks:start(true, self.node, {
            virt_text = { { self.config.text, self.config.highlight } },
            virt_text_pos = 'inline',
        })
    end
end

return Render
