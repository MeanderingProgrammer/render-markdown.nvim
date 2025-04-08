---@class (exact) render.md.callback.Config
---@field attach fun(ctx: render.md.callback.Context)
---@field render fun(ctx: render.md.callback.Context)
---@field clear fun(ctx: render.md.callback.Context)

---@class (exact) render.md.callback.Context
---@field buf integer

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:type('attach', 'function')
    spec:type('render', 'function')
    spec:type('clear', 'function')
    spec:check()
end

return M
