---@class render.md.request.checkbox.Value
---@field node render.md.Node
---@field config render.md.checkbox.component.Config

---@class render.md.request.Checkbox
---@field private values table<integer, render.md.request.checkbox.Value>
local Checkbox = {}
Checkbox.__index = Checkbox

---@return render.md.request.Checkbox
function Checkbox.new()
    local self = setmetatable({}, Checkbox)
    self.values = {}
    return self
end

---@param node render.md.Node
---@param config render.md.checkbox.custom.Config
function Checkbox:set(node, config)
    self.values[node.start_row] = {
        node = node,
        config = {
            icon = config.rendered,
            highlight = config.highlight,
            scope_highlight = config.scope_highlight,
        },
    }
end

---@param node render.md.Node
---@return render.md.request.checkbox.Value?
function Checkbox:get(node)
    return self.values[node.start_row]
end

return Checkbox
