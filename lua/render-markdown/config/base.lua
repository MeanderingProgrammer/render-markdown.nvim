---@class (exact) render.md.base.Config
---@field enabled boolean
---@field render_modes render.md.Modes

---@alias render.md.Modes boolean|string[]

---@class render.md.base.Cfg
local M = {}

---@param child render.md.schema.Record
---@return render.md.Schema
function M.schema(child)
    ---@type render.md.schema.Record
    local parent = {
        enabled = { type = 'boolean' },
        render_modes = {
            union = { { list = { type = 'string' } }, { type = 'boolean' } },
        },
    }
    ---@type render.md.Schema
    return { record = vim.tbl_deep_extend('error', parent, child) }
end

return M
