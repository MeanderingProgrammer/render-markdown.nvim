local Base = require('render-markdown.render.base')

---@class render.md.render.Checkbox: render.md.Renderer
---@field private checkbox render.md.CheckboxComponent
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    local config = self.config.checkbox
    if self.context:skip(config) then
        return false
    end

    local types = {
        task_list_marker_unchecked = config.unchecked,
        task_list_marker_checked = config.checked,
    }
    self.checkbox = types[self.node.type]
    if self.checkbox == nil then
        return false
    end

    return true
end

function Render:render()
    self:check_icon(self.checkbox.icon, self.checkbox.highlight)
    self:scope('check_scope', self.node:sibling('paragraph'), self.checkbox.scope_highlight)
end

return Render
