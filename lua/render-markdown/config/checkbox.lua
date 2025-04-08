---@class (exact) render.md.checkbox.Config: render.md.base.Config
---@field right_pad integer
---@field unchecked render.md.checkbox.component.Config
---@field checked render.md.checkbox.component.Config
---@field custom table<string, render.md.checkbox.custom.Config>

---@class (exact) render.md.checkbox.component.Config
---@field icon string
---@field highlight string
---@field scope_highlight? string

---@class (exact) render.md.checkbox.custom.Config
---@field raw string
---@field rendered string
---@field highlight string
---@field scope_highlight? string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('right_pad', 'number')
    spec:nested({ 'unchecked', 'checked' }, function(box)
        box:type('icon', 'string')
        box:type('highlight', 'string')
        box:type('scope_highlight', { 'string', 'nil' })
        box:check()
    end)
    spec:nested('custom', function(boxes)
        boxes:each(function(box)
            box:type('raw', 'string')
            box:type('rendered', 'string')
            box:type('highlight', 'string')
            box:type('scope_highlight', { 'string', 'nil' })
            box:check()
        end)
        boxes:check()
    end)
    spec:check()
end

return M
