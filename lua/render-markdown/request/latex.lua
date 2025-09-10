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

---@return render.md.Node[][]
function Latex:get()
    table.sort(self.nodes)
    local result = {} ---@type render.md.Node[][]
    result[#result + 1] = { self.nodes[1] }
    for i = 2, #self.nodes do
        local node, last = self.nodes[i], result[#result]
        if node.start_row == last[#last].start_row then
            last[#last + 1] = node
        else
            result[#result + 1] = { node }
        end
    end
    return result
end

return Latex
