local Base = require('render-markdown.render.base')
local Bullet = require('render-markdown.render.markdown.bullet')
local Checkbox = require('render-markdown.render.markdown.checkbox')

---@class render.md.render.List: render.md.Render
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    return true
end

---@protected
function Render:run()
    if not Checkbox:execute(self.context, self.marks, self.node) then
        Bullet:execute(self.context, self.marks, self.node)
    end
end

return Render
