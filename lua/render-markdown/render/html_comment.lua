local Base = require('render-markdown.render.base')

---@class render.md.render.html.Comment: render.md.Render
---@field private info render.md.html.comment.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.html.comment
    if not self.info.conceal then
        return false
    end
    return true
end

function Render:render()
    self.marks:over(true, self.node, { conceal = '' })
    if self.info.text ~= nil then
        self.marks:start(true, self.node, {
            virt_text = { { self.info.text, self.info.highlight } },
            virt_text_pos = 'inline',
        })
    end
end

return Render
