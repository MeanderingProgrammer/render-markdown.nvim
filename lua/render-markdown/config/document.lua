---@class (exact) render.md.document.Config: render.md.base.Config
---@field conceal render.md.document.conceal.Config

---@class (exact) render.md.document.conceal.Config
---@field char_patterns string[]
---@field line_patterns string[]

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:nested('conceal', function(conceal)
        conceal:list('char_patterns', 'string')
        conceal:list('line_patterns', 'string')
        conceal:check()
    end)
    spec:check()
end

return M
