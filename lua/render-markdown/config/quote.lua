---@class (exact) render.md.quote.Config: render.md.base.Config
---@field icon string|string[]
---@field repeat_linebreak boolean
---@field highlight string|string[]

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:list('icon', 'string', 'string')
    spec:type('repeat_linebreak', 'boolean')
    spec:list('highlight', 'string', 'string')
    spec:check()
end

return M
