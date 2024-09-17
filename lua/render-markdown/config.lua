---@class render.md.component.Config
---@field callout table<string, render.md.CustomComponent>
---@field checkbox table<string, render.md.CustomComponent>

---@class render.md.buffer.Config: render.md.BufferConfig
---@field component render.md.component.Config
local Config = {}
Config.__index = Config

---@param config render.md.BufferConfig
---@return render.md.buffer.Config
function Config.new(config)
    ---@type render.md.component.Config
    local component = {
        callout = Config.normalize(config.callout),
        checkbox = Config.normalize(config.checkbox.custom),
    }
    local instance = vim.tbl_deep_extend('force', { component = component }, config)
    return setmetatable(instance, Config)
end

---@private
---@param components table<string, render.md.CustomComponent>
function Config.normalize(components)
    local result = {}
    for _, component in pairs(components) do
        result[component.raw:lower()] = component
    end
    return result
end

---@param mode string
---@return boolean
function Config:render(mode)
    local modes = self.render_modes
    if type(modes) == 'table' then
        return vim.tbl_contains(modes, mode)
    else
        return modes
    end
end

return Config
