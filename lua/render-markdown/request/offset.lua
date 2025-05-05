---@class render.md.request.offset.Value
---@field col integer
---@field width integer

---@class render.md.request.Offset
---@field private values table<integer, render.md.request.offset.Value[]>
local Offset = {}
Offset.__index = Offset

---@return render.md.request.Offset
function Offset.new()
    local self = setmetatable({}, Offset)
    self.values = {}
    return self
end

---@param row integer
---@param value render.md.request.offset.Value
function Offset:add(row, value)
    if value.width <= 0 then
        return
    end
    if not self.values[row] then
        self.values[row] = {}
    end
    local values = self.values[row]
    values[#values + 1] = value
end

---@param node render.md.Node
---@return integer
function Offset:get(node)
    local result = 0
    local values = self.values[node.start_row] or {}
    for _, value in ipairs(values) do
        if node.start_col <= value.col and node.end_col > value.col then
            result = result + value.width
        end
    end
    return result
end

return Offset
