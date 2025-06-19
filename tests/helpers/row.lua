---@class render.md.test.Row
---@field private value integer
local Row = {}
Row.__index = Row

---@return render.md.test.Row
function Row.new()
    local self = setmetatable({}, Row)
    self.value = 0
    return self
end

---@param soff integer
---@param eoff? integer
---@return render.md.test.Range
function Row:get(soff, eoff)
    ---@type render.md.test.Range
    return { self:inc(soff), eoff and self:inc(eoff) or nil }
end

---@private
---@param n integer
---@return integer
function Row:inc(n)
    self.value = self.value + n
    return self.value
end

return Row
