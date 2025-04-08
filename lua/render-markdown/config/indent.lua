---@class (exact) render.md.indent.Config: render.md.base.Config
---@field per_level integer
---@field skip_level integer
---@field skip_heading boolean
---@field icon string
---@field highlight string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('per_level', 'number')
    spec:type('skip_level', 'number')
    spec:type('skip_heading', 'boolean')
    spec:type('icon', 'string')
    spec:type('highlight', 'string')
    spec:check()
end

return M
