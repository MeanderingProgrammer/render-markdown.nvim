---@class (exact) render.md.inline.highlight.Config: render.md.base.Config
---@field highlight string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('highlight', 'string')
    spec:check()
end

return M
