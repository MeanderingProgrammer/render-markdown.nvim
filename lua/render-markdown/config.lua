local Range = require('render-markdown.core.range')

---@class render.md.component.Config
---@field callout table<string, render.md.CustomCallout>
---@field checkbox table<string, render.md.CustomCheckbox>

---@class render.md.buffer.Config: render.md.BufferConfig
---@field private component render.md.component.Config
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
---@generic T: render.md.CustomCallout|render.md.CustomCheckbox
---@param components table<string, T>
---@return table<string, T>
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

---@param node render.md.Node
---@return render.md.CustomCallout?
function Config:get_callout(node)
    return self.component.callout[node.text:lower()]
end

---@param node render.md.Node
---@return render.md.CustomCheckbox?
function Config:get_checkbox(node)
    return self.component.checkbox[node.text:lower()]
end

---@param mode string
---@param row? integer
---@return render.md.Range?
function Config:hidden(mode, row)
    -- Anti-conceal is not enabled -> hide nothing
    -- Row is not known means buffer is not active -> hide nothing
    if not self.anti_conceal.enabled or row == nil then
        return nil
    end
    if vim.tbl_contains({ 'v', 'V', '\22' }, mode) then
        local start = vim.fn.getpos('v')[2] - 1
        return Range.new(math.min(row, start), math.max(row, start))
    else
        return Range.new(row - self.anti_conceal.above, row + self.anti_conceal.below)
    end
end

return Config
