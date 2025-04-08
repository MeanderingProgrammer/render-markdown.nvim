local Base = require('render-markdown.render.base')

---@class render.md.render.html.Tag: render.md.Renderer
---@field private info render.md.html.Tag
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    local tag = self.node:child('start_tag')
    if tag == nil then
        return false
    end
    local name = tag:child('tag_name')
    if name == nil then
        return false
    end
    self.info = self.config.html.tag[name.text]
    return self.info ~= nil
end

function Render:render()
    self.marks:over(true, self.node:child('start_tag'), { conceal = '' })
    self.marks:over(true, self.node:child('end_tag'), { conceal = '' })
    self.marks:start(false, self.node, {
        virt_text = { { self.info.icon, self.info.highlight } },
        virt_text_pos = 'inline',
    })
end

return Render
