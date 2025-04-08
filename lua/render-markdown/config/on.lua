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
        :type('render', 'function')
        :type('clear', 'function')
        :check()
end

return M
