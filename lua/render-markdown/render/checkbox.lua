local Base = require('render-markdown.render.base')
local Str = require('render-markdown.lib.str')

---@class render.md.render.Checkbox: render.md.Renderer
---@field private checkbox render.md.CheckboxComponent
---@field private inline boolean
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    local checkbox = self.config.checkbox
    if self.context:skip(checkbox) then
        return false
    end

    local type_mapping = {
        task_list_marker_unchecked = checkbox.unchecked,
        task_list_marker_checked = checkbox.checked,
    }
    self.checkbox = type_mapping[self.node.type]
    if self.checkbox == nil then
        return false
    end

    self.inline = checkbox.position == 'inline'

    return true
end

function Render:render()
    self:icon()
    self:scope('check_scope', self.node:sibling('paragraph'), self.checkbox.scope_highlight)
end

---@private
function Render:icon()
    local icon = self.checkbox.icon
    local text = self.inline and icon or Str.pad_to(self.node.text, icon) .. icon
    self.marks:add_over('check_icon', self.node, {
        virt_text = { { text, self.checkbox.highlight } },
        virt_text_pos = self.inline and 'inline' or 'overlay',
        conceal = self.inline and '' or nil,
    })
end

return Render
