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

---@return render.md.Schema
function M.schema()
    ---@type render.md.Schema
    local handler = {
        record = {
            extends = { optional = true, type = 'boolean' },
            parse = { type = 'function' },
        },
    }
    ---@type render.md.Schema
    return { map = { key = { type = 'string' }, value = handler } }
end

return M
