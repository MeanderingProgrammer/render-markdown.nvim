---@class (exact) render.md.completions.Config
---@field blink render.md.completion.Config
---@field coq render.md.completion.Config
---@field lsp render.md.completion.Config
---@field filter render.md.completion.filter.Config

---@class (exact) render.md.completion.Config
---@field enabled boolean

---@class (exact) render.md.completion.filter.Config
---@field callout fun(value: render.md.callout.Config): boolean
---@field checkbox fun(value: render.md.checkbox.custom.Config): boolean

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:nested({ 'blink', 'coq', 'lsp' }, function(completion)
        completion:type('enabled', 'boolean')
        completion:check()
    end)
    spec:nested('filter', function(filter)
        filter:type('callout', 'function')
        filter:type('checkbox', 'function')
        filter:check()
    end)
    spec:check()
end

return M
