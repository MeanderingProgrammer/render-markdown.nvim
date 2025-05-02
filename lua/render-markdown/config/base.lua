---@class (exact) render.md.base.Config
---@field enabled boolean
---@field render_modes render.md.Modes

---@alias render.md.Modes boolean|string[]

---@class render.md.base.Cfg
local M = {}

---@enum render.md.base.Width
M.Width = {
    full = 'full',
    block = 'block',
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:type('enabled', 'boolean')
    spec:list('render_modes', 'string', 'boolean')
end

return M
