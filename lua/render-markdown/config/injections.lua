---@class (exact) render.md.injection.Config
---@field enabled boolean
---@field query string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:each(function(injection)
        injection:type('enabled', 'boolean')
        injection:type('query', 'string')
        injection:check()
    end)
    spec:check()
end

return M
