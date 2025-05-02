---@class (exact) render.md.on.Config
---@field attach fun(ctx: render.md.on.attach.Context)
---@field initial fun(ctx: render.md.on.render.Context)
---@field render fun(ctx: render.md.on.render.Context)
---@field clear fun(ctx: render.md.on.render.Context)

---@class (exact) render.md.on.attach.Context
---@field buf integer

---@class (exact) render.md.on.render.Context
---@field buf integer
---@field win integer

---@class render.md.on.Cfg
local M = {}

---@type render.md.on.Config
M.default = {
    -- Called when plugin initially attaches to a buffer.
    attach = function() end,
    -- Called before adding marks to the buffer for the first time.
    initial = function() end,
    -- Called after plugin renders a buffer.
    render = function() end,
    -- Called after plugin clears a buffer.
    clear = function() end,
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:type('attach', 'function')
    spec:type('initial', 'function')
    spec:type('render', 'function')
    spec:type('clear', 'function')
    spec:check()
end

return M
