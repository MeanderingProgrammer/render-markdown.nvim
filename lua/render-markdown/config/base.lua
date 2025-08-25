---@class (exact) render.md.base.Config
---@field enabled boolean
---@field render_modes render.md.Modes

---@alias render.md.Modes boolean|string[]

---@class render.md.base.Cfg
local M = {}

---@param additional_fields render.md.schema.Fields
---@return render.md.Schema
function M.schema(additional_fields)
    ---@type render.md.schema.Fields
    local fields = {
        enabled = { type = 'boolean' },
        render_modes = {
            union = { { list = { type = 'string' } }, { type = 'boolean' } },
        },
    }
    ---@type render.md.Schema
    return { record = vim.tbl_deep_extend('error', fields, additional_fields) }
end

return M
