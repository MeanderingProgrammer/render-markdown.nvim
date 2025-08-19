---@class render.md.Range
---@field [1] integer
---@field [2] integer

---@class render.md.Interval
local M = {}

---noncommutative
---@param a render.md.Range
---@param b render.md.Range
---@return boolean
function M.contains(a, b)
    return a[1] <= b[1] and a[2] >= b[2]
end

---commutative
---@param a render.md.Range
---@param b render.md.Range
---@param exclusive? boolean
---@return boolean
function M.overlaps(a, b, exclusive)
    if exclusive then
        return b[1] < a[2] and b[2] > a[1]
    else
        return b[1] <= a[2] and b[2] >= a[1]
    end
end

---@param ranges render.md.Range[]
---@return render.md.Range[]
function M.coalesce(ranges)
    table.sort(ranges, function(a, b)
        if a[1] ~= b[1] then
            return a[1] < b[1]
        else
            return a[2] < b[2]
        end
    end)
    local result = {} ---@type render.md.Range[]
    result[#result + 1] = ranges[1]
    for i = 2, #ranges do
        local range, last = ranges[i], result[#result]
        if range[1] <= last[2] + 1 then
            last[2] = math.max(last[2], range[2])
        else
            result[#result + 1] = range
        end
    end
    return result
end

return M
