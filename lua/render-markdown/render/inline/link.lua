local Base = require('render-markdown.render.base')

---@class render.md.link.Data
---@field icon render.md.mark.Text
---@field autolink boolean

---@class render.md.render.inline.Link: render.md.Render
---@field private data render.md.link.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    local config = self.context.config.link
    if self.context:skip(config) then
        return false
    end
    if self.node:descendant('shortcut_link') then
        return false
    end
    ---@type render.md.mark.Text
    local icon = { config.hyperlink, config.highlight }
    local autolink = false
    if self.node.type == 'email_autolink' then
        icon[1] = config.email
        autolink = true
    elseif self.node.type == 'image' then
        icon[1] = config.image
        local destination = self.node:child('link_destination')
        if destination then
            self.context.config:set_link_text(destination.text, icon)
        end
    elseif self.node.type == 'inline_link' then
        local destination = self.node:child('link_destination')
        if destination then
            self.context.config:set_link_text(destination.text, icon)
        end
    elseif self.node.type == 'uri_autolink' then
        local destination = self.node.text:sub(2, -2)
        self.context.config:set_link_text(destination, icon)
        autolink = true
    end
    self.data = { icon = icon, autolink = autolink }
    return true
end

---@protected
function Render:run()
    self.marks:start('link', self.node, {
        hl_mode = 'combine',
        virt_text = { self.data.icon },
        virt_text_pos = 'inline',
    })
    if self.data.autolink then
        self:hide(self.node.start_col, self.node.start_col + 1)
        self.marks:over('link', self.node, { hl_group = self.data.icon[2] })
        self:hide(self.node.end_col - 1, self.node.end_col)
    end
end

---@private
---@param start_col integer
---@param end_col integer
function Render:hide(start_col, end_col)
    self.marks:add(true, self.node.start_row, start_col, {
        end_col = end_col,
        conceal = '',
    })
end

return Render
