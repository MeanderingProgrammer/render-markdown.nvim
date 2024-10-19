local Base = require('render-markdown.render.base')
local str = require('render-markdown.core.str')

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

    local text, highlight, conceal = self.link.hyperlink, self.link.highlight, false
    if self.info.type == 'email_autolink' then
        text, conceal = self.link.email .. self.info.text:sub(2, -2), true
    elseif self.info.type == 'image' then
        text = self.link.image
    elseif self.info.type == 'inline_link' then
        local destination = self.info:child('link_destination')
        local link_component = destination ~= nil and self:link_component(destination.text) or nil
        if link_component ~= nil then
            text, highlight = link_component.icon, link_component.highlight
        end
    end
    self.data = { text = text, highlight = highlight, conceal = conceal }

    return true
end

function Render:render()
    local added = self.marks:add('link', self.info.start_row, self.info.start_col, {
        end_row = self.info.end_row,
        end_col = self.info.end_col,
        virt_text = { { self.data.text, self.data.highlight } },
        virt_text_pos = 'inline',
        conceal = self.data.conceal and '' or nil,
    })
    if not self.data.conceal and added then
        self.context:add_offset(self.info, str.width(self.data.text))
    end
end

return Render
