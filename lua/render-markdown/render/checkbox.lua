local Base = require('render-markdown.render.base')
local str = require('render-markdown.core.str')

---@class render.md.render.Checkbox: render.md.Renderer
---@field private checkbox render.md.CheckboxComponent
---@field private inline boolean
local Render = setmetatable({}, Base)
Render.__index = Render

---@param marks render.md.Marks
---@param config render.md.buffer.Config
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Render:new(marks, config, context, info)
    return Base.new(self, marks, config, context, info)
end

---@return boolean
function Render:setup()
    local checkbox = self.config.checkbox
    if not checkbox.enabled then
        return false
    end

    local type_mapping = {
        task_list_marker_unchecked = checkbox.unchecked,
        task_list_marker_checked = checkbox.checked,
    }
    self.checkbox = type_mapping[self.info.type]
    if self.checkbox == nil then
        return false
    end

    self.inline = checkbox.position == 'inline'

    return true
end

function Render:render()
    local icon = self.checkbox.icon
    local text = self.inline and icon or str.pad_to(self.info.text, icon) .. icon
    self.marks:add(true, self.info.start_row, self.info.start_col, {
        end_row = self.info.end_row,
        end_col = self.info.end_col,
        virt_text = { { text, self.checkbox.highlight } },
        virt_text_pos = self.inline and 'inline' or 'overlay',
        conceal = self.inline and '' or nil,
    })
end

return Render
