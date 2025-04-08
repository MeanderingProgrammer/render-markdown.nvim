---@class (exact) render.md.quote.Config: render.md.base.Config
---@field icon string
---@field repeat_linebreak boolean
---@field highlight string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('icon', 'string')
    spec:type('repeat_linebreak', 'boolean')
    spec:type('highlight', 'string')
    spec:check()
end

return M
