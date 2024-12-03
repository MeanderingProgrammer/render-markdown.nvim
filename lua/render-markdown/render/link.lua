local Base = require('render-markdown.render.base')

---@class render.md.data.Link
---@field text string
---@field highlight string
---@field conceal boolean

---@class render.md.render.Link: render.md.Renderer
---@field private link render.md.Link
---@field private data render.md.data.Link
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.link = self.config.link
    if not self.link.enabled then
        return false
    end

    if self.node.type == 'email_autolink' then
        local email = self.node.text:sub(2, -2)
        self.data = {
            text = self.link.email .. email,
            highlight = self.link.highlight,
            conceal = true,
        }
    elseif self.node.type == 'full_reference_link' then
        self.data = {
            text = self.link.hyperlink,
            highlight = self.link.highlight,
            conceal = false,
        }
    elseif self.node.type == 'image' then
        self.data = {
            text = self.link.image,
            highlight = self.link.highlight,
            conceal = false,
        }
    elseif self.node.type == 'inline_link' then
        local destination = self.node:child('link_destination')
        local component = destination ~= nil and self:link_component(destination.text) or nil
        local text, highlight = self.link.hyperlink, nil
        if component ~= nil then
            text, highlight = component.icon, component.highlight
        end
        self.data = {
            text = text,
            highlight = highlight or self.link.highlight,
            conceal = false,
        }
    elseif self.node.type == 'uri_autolink' then
        local destination = self.node.text:sub(2, -2)
        local component = self:link_component(destination)
        local text, highlight = self.link.hyperlink, nil
        if component ~= nil then
            text, highlight = component.icon, component.highlight
        end
        self.data = {
            text = text .. destination,
            highlight = highlight or self.link.highlight,
            conceal = true,
        }
    else
        return false
    end

    return true
end

function Render:render()
    self.marks:add_over('link', self.node, {
        virt_text = { { self.data.text, self.data.highlight } },
        virt_text_pos = 'inline',
        conceal = self.data.conceal and '' or nil,
    })
end

return Render
