local Base = require('render-markdown.render.base')

---@class render.md.render.HtmlTag: render.md.Renderer
---@field private tag render.md.HtmlTag
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
    self.tag = self.config.html.tag[name.text]
    return self.tag ~= nil
end

function Render:render()
    self.marks:over(true, self.node:child('start_tag'), { conceal = '' })
    self.marks:over(true, self.node:child('end_tag'), { conceal = '' })
    self.marks:start(false, self.node, {
        virt_text = { { self.tag.icon, self.tag.highlight } },
        virt_text_pos = 'inline',
    })
end

return Render
