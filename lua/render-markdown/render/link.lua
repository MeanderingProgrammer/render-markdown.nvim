local Base = require('render-markdown.render.base')

---@class render.md.link.Data
---@field icon string
---@field highlight string
---@field autolink boolean

---@class render.md.render.Link: render.md.Render
---@field private data render.md.link.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    local link = self.config.link
    if self.context:skip(link) then
        return false
    end

    local icon, highlight, autolink = link.hyperlink, link.highlight, false
    if self.node.type == 'email_autolink' then
        icon = link.email
        autolink = true
    elseif self.node.type == 'image' then
        icon = link.image
    elseif self.node.type == 'inline_link' then
        local destination = self.node:child('link_destination')
        if destination ~= nil then
            icon, highlight = self:dest(icon, highlight, destination.text)
        end
    elseif self.node.type == 'uri_autolink' then
        local destination = self.node.text:sub(2, -2)
        icon, highlight = self:dest(icon, highlight, destination)
        autolink = true
    end
    self.data = { icon = icon, highlight = highlight, autolink = autolink }

    return true
end

function Render:render()
    self.marks:start('link', self.node, {
        virt_text = { { self.data.icon, self.data.highlight } },
        virt_text_pos = 'inline',
    })
    if self.data.autolink then
        self:hide_bracket(self.node.start_col)
        self.marks:over('link', self.node, { hl_group = self.data.highlight })
        self:hide_bracket(self.node.end_col - 1)
    end
end

---@private
---@param col integer
function Render:hide_bracket(col)
    self.marks:add(true, self.node.start_row, col, {
        end_col = col + 1,
        conceal = '',
    })
end

return Render
