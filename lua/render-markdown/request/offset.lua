---@class render.md.request.offset.Value
---@field col integer
---@field width integer
---@field virt_text render.md.mark.Line original virtual text segments

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

---@param body render.md.node.Body
---@return integer
function Offset:get(body)
    local result = 0
    local values = self.values[body.start_row] or {}
    for _, value in ipairs(values) do
        if body.start_col <= value.col and body.end_col > value.col then
            result = result + value.width
        end
    end
    return result
end

---Return injections within a column range on a row, sorted by col.
---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.request.offset.Value[]
function Offset:range(row, start_col, end_col)
    local result = {} ---@type render.md.request.offset.Value[]
    for _, value in ipairs(self.values[row] or {}) do
        if value.col >= start_col and value.col < end_col then
            result[#result + 1] = value
        end
    end
    table.sort(result, function(a, b) return a.col < b.col end)
    return result
end

return Offset
