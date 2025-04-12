---@class (exact) render.md.callback.Config
---@field attach fun(ctx: render.md.callback.attach.Context)
---@field initial fun(ctx: render.md.callback.render.Context)
---@field render fun(ctx: render.md.callback.render.Context)
---@field clear fun(ctx: render.md.callback.render.Context)

---@class (exact) render.md.callback.attach.Context
---@field buf integer

---@class (exact) render.md.callback.render.Context
---@field buf integer
---@field win integer

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:type('attach', 'function')
    spec:type('initial', 'function')
    spec:type('render', 'function')
    spec:type('clear', 'function')
    spec:check()
end

return M
