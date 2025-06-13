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
    for _, component in pairs(config) do
        if type(component) == 'table' then
            self.modes = Resolved.fold(self.modes, component['render_modes'])
        end
    end
    self.callouts = Resolved.normalize(config.callout)
    self.checkboxes = Resolved.normalize(config.checkbox.custom)
    return self
end

---@private
---@param acc render.md.Modes
---@param new? render.md.Modes
---@return render.md.Modes
function Resolved.fold(acc, new)
    if type(acc) == 'boolean' and type(new) == 'boolean' then
        return acc or new
    elseif type(acc) == 'boolean' and type(new) == 'table' then
        return acc or new
    elseif type(acc) == 'table' and type(new) == 'boolean' then
        return new or acc
    elseif type(acc) == 'table' and type(new) == 'table' then
        -- copy to avoid modifying inputs
        local result = {}
        vim.list_extend(result, acc)
        vim.list_extend(result, new)
        return result
    else
        -- should only occur if new is nil, keep current value
        return acc
    end
end

---@private
---@generic T: render.md.callout.Config|render.md.checkbox.custom.Config
---@param component table<string, T>
---@return table<string, T>
function Resolved.normalize(component)
    local result = {}
    for _, value in pairs(component) do
        result[value.raw:lower()] = value
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
