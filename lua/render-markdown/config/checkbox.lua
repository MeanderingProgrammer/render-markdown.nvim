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
        :nested({ 'unchecked', 'checked' }, function(box)
            box:type('icon', 'string')
                :type('highlight', 'string')
                :type('scope_highlight', { 'string', 'nil' })
                :check()
        end)
        :nested('custom', function(boxes)
            boxes:each(function(box)
                box:type('raw', 'string')
                    :type('rendered', 'string')
                    :type('highlight', 'string')
                    :type('scope_highlight', { 'string', 'nil' })
                    :check()
            end)
        end)
        :check()
end

return M
