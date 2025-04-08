---@class (exact) render.md.pattern.Config
---@field disable boolean
---@field directives render.md.directive.Config[]

---@class (exact) render.md.directive.Config
---@field id integer
---@field name string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:each(function(pattern)
        pattern:type('disable', 'boolean')
        pattern:nested('directives', function(directives)
            directives:each(function(directive)
                directive:type('id', 'number')
                directive:type('name', 'string')
                directive:check()
            end)
            directives:check()
        end)
        pattern:check()
    end)
    spec:check()
end

return M
