---@class (exact) render.md.base.Config
---@field enabled boolean
---@field render_modes render.md.Modes

---@alias render.md.Modes boolean|string[]

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:type('enabled', 'boolean')
    spec:list('render_modes', 'string', 'boolean')
end

return M
