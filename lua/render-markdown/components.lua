---@class render.md.component.Config
---@field callout table<string, render.md.CustomComponent>
---@field checkbox table<string, render.md.CustomComponent>

---@class render.md.buffer.Config: render.md.BufferConfig
---@field component render.md.component.Config

---@class render.md.component.Resolver
local M = {}

---@param config render.md.BufferConfig
---@return render.md.buffer.Config
function M.resolve(config)
    ---@type render.md.component.Config
    local component = {
        callout = M.normalize(config.callout),
        checkbox = M.normalize(config.checkbox.custom),
    }
    return vim.tbl_deep_extend('force', { component = component }, config)
end

---@private
---@param components table<string, render.md.CustomComponent>
function M.normalize(components)
    local result = {}
    for _, component in pairs(components) do
        result[component.raw:lower()] = component
    end
    return result
end

return M
