---@class (exact) render.md.dash.Config: render.md.base.Config
---@field icon string
---@field width 'full'|number
---@field left_margin number
---@field highlight string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('icon', 'string')
        :one_of('width', { 'full' }, 'number')
        :type('left_margin', 'number')
        :type('highlight', 'string')
        :check()
end

return M
