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

---@return integer
function Row:get()
    return self.value
end

---@param n? integer
---@return integer
function Row:inc(n)
    self.value = self.value + (n or 1)
    return self.value
end

return Row
