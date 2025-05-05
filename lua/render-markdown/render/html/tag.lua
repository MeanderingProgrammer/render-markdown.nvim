local Base = require('render-markdown.render.base')

---@class render.md.render.html.Tag: render.md.Render
---@field private config render.md.html.Tag
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    local tag = self.node:child('start_tag')
    if not tag then
        return false
    end
    local name = tag:child('tag_name')
    if not name then
        return false
    end
    self.config = self.context.config.html.tag[name.text]
    return self.config ~= nil
end

---@protected
function Render:run()
    self.marks:over(true, self.node:child('start_tag'), { conceal = '' })
    self.marks:over(true, self.node:child('end_tag'), { conceal = '' })
    self.marks:start(false, self.node, {
        virt_text = { { self.config.icon, self.config.highlight } },
        virt_text_pos = 'inline',
    })
end

return Render
