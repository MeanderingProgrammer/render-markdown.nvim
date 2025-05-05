---@class render.md.request.callout.Value
---@field node render.md.Node
---@field config render.md.callout.Config

---@class render.md.request.Callout
---@field private values table<integer, render.md.request.callout.Value>
local Callout = {}
Callout.__index = Callout

---@return render.md.request.Callout
function Callout.new()
    local self = setmetatable({}, Callout)
    self.values = {}
    return self
end

---@param node render.md.Node
---@param config render.md.callout.Config
function Callout:set(node, config)
    self.values[node.start_row] = { node = node, config = config }
end

---@param node render.md.Node
---@return render.md.request.callout.Value?
function Callout:get(node)
    return self.values[node.start_row]
end

return Callout
