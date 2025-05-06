---@class render.md.request.Used
---@field private values table<integer, boolean>
local Used = {}
Used.__index = Used

---@return render.md.request.Used
function Used.new()
    local self = setmetatable({}, Used)
    self.values = {}
    return self
end

---@param row integer
---@return boolean
function Used:take(row)
    if self.values[row] then
        return false
    end
    self.values[row] = true
    return true
end

return Used
