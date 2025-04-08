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
    spec:one_of('width', { 'full' }, 'number')
    spec:type('left_margin', 'number')
    spec:type('highlight', 'string')
    spec:check()
end

return M
