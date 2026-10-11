---@class render.md.request.latex.Item
---@field node render.md.Node
---@field width integer
---@field above string[]
---@field below string[]

---@class render.md.request.latex.Row
---@field highlight string
---@field items render.md.request.latex.Item[]
---@field above? render.md.Mark
---@field below? render.md.Mark

---@class render.md.request.Latex
---@field private nodes render.md.Node[]
---@field private rows table<integer, render.md.request.latex.Row>
local Latex = {}
Latex.__index = Latex

---@return render.md.request.Latex
function Latex.new()
    local self = setmetatable({}, Latex)
    self.nodes = {}
    self.rows = {}
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

---@param row integer
---@param value render.md.request.latex.Row
function Latex:set_row(row, value)
    self.rows[row] = value
end

---Lets another renderer, i.e. tables, take ownership of the virtual lines
---@param row integer
---@return render.md.request.latex.Row?
function Latex:take_row(row)
    local value = self.rows[row]
    self.rows[row] = nil
    return value
end

return Latex
