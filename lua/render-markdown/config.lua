local Range = require('render-markdown.core.range')
local util = require('render-markdown.core.util')

---@class render.md.component.Config
---@field callout table<string, render.md.CustomCallout>
---@field checkbox table<string, render.md.CustomCheckbox>

---@class render.md.buffer.Config: render.md.BufferConfig
---@field private modes render.md.Modes
---@field private component render.md.component.Config
local Config = {}
Config.__index = Config

---@param config render.md.BufferConfig
---@return render.md.buffer.Config
function Config.new(config)
    -- Super set of render modes across top level and individual components
    local modes = config.render_modes
    for _, component in pairs(config) do
        if type(component) == 'table' then
            modes = Config.fold_modes(modes, component['render_modes'])
        end
    end

    ---@type render.md.component.Config
    local component = {
        callout = Config.normalize(config.callout),
        checkbox = Config.normalize(config.checkbox.custom),
    }

    local instance = vim.tbl_deep_extend('force', { modes = modes, component = component }, config)
    return setmetatable(instance, Config)
end

---@private
---@param current render.md.Modes
---@param new? render.md.Modes
---@return render.md.Modes
function Config.fold_modes(current, new)
    if type(current) == 'boolean' and type(new) == 'boolean' then
        return current or new
    elseif type(current) == 'boolean' and type(new) == 'table' then
        return current or new
    elseif type(current) == 'table' and type(new) == 'boolean' then
        return new or current
    elseif type(current) == 'table' and type(new) == 'table' then
        -- Copy to avoid modifying inputs
        local result = {}
        vim.list_extend(result, current)
        vim.list_extend(result, new)
        return result
    else
        -- Should only occur if new is nil, keep current value
        return current
    end
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
    return util.in_modes(self.modes, mode)
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
