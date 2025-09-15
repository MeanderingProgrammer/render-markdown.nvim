---@class render.md.request.Latex
---@field private nodes render.md.Node[]
local Latex = {}
Latex.__index = Latex

---@return render.md.request.Latex
function Latex.new()
    local self = setmetatable({}, Latex)
    self.nodes = {}
    return self
end

---@param node render.md.Node
function Latex:add(node)
    self.nodes[#self.nodes + 1] = node
end

---@return render.md.Node[]
function Latex:get()
    return self.nodes
end

return Latex
