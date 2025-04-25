local Base = require('render-markdown.render.base')

---@class render.md.link.Data
---@field icon render.md.mark.Text
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
    if self.node:descendant('shortcut_link') ~= nil then
        return false
    end
    ---@type render.md.mark.Text
    local icon = { link.hyperlink, link.highlight }
    local autolink = false
    if self.node.type == 'email_autolink' then
        icon[1] = link.email
        autolink = true
    elseif self.node.type == 'image' then
        icon[1] = link.image
    elseif self.node.type == 'inline_link' then
        local destination = self.node:child('link_destination')
        if destination ~= nil then
            self:link_icon(destination.text, icon)
        end
    elseif self.node.type == 'uri_autolink' then
        local destination = self.node.text:sub(2, -2)
        self:link_icon(destination, icon)
        autolink = true
    end
    self.data = { icon = icon, autolink = autolink }
    return true
end

function Render:render()
    self.marks:start('link', self.node, {
        hl_mode = 'combine',
        virt_text = { self.data.icon },
        virt_text_pos = 'inline',
    })
    if self.data.autolink then
        self:hide_bracket(self.node.start_col)
        self.marks:over('link', self.node, { hl_group = self.data.icon[2] })
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
