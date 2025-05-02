---@class (exact) render.md.Handler
---@field extends? boolean
---@field parse fun(ctx: render.md.handler.Context): render.md.Mark[]

---@class (exact) render.md.handler.Context
---@field buf integer
---@field root TSNode

---@class render.md.handlers.Cfg
local M = {}

---@type table<string, render.md.Handler>
M.default = {
    -- Mapping from treesitter language to user defined handlers.
    -- @see [Custom Handlers](doc/custom-handlers.md)
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:each(function(handler)
        handler:type('extends', { 'boolean', 'nil' })
        handler:type('parse', 'function')
        handler:check()
    end)
    spec:check()
end

return M
