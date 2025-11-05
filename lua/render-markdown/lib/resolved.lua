local env = require('render-markdown.lib.env')

---@class render.md.resolved.Config
---@field private modes render.md.Modes
---@field private callouts table<string, render.md.callout.Config>
---@field private checkboxes table<string, render.md.checkbox.custom.Config>
local Resolved = {}
Resolved.__index = Resolved

---@param config render.md.partial.Config
---@return render.md.resolved.Config
function Resolved.new(config)
    local self = setmetatable({}, Resolved)
    -- super set of render modes across top level and individual components
    self.modes = config.render_modes
    local components = config ---@type table<string, render.md.base.Config>
    for _, component in pairs(components) do
        if type(component) == 'table' then
            self.modes = env.mode.join(self.modes, component.render_modes)
        end
    end
    self.callouts = Resolved.normalize(config.callout)
    self.checkboxes = Resolved.normalize(config.checkbox.custom)
    return self
end

---@private
---@generic T: render.md.raw.Config
---@param configs table<string, T>
---@return table<string, T>
function Resolved.normalize(configs)
    local result = {} ---@type table<string, any>
    for _, config in pairs(configs) do
        result[config.raw:lower()] = config
    end
    return result
end

---@param mode string
---@return boolean
function Resolved:render(mode)
    return env.mode.is(mode, self.modes)
end

---@param node render.md.Node
---@return render.md.callout.Config?
function Resolved:callout(node)
    return self.callouts[node.text:lower()]
end

---@param node render.md.Node
---@return render.md.checkbox.custom.Config?
function Resolved:checkbox(node)
    return self.checkboxes[node.text:lower()]
end

return Resolved
