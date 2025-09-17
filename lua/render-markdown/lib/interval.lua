---@class render.md.Range: Range2
---@field [1] integer start
---@field [2] integer end

---@class render.md.Interval
local M = {}

---@param range render.md.Range
---@param exclusive? boolean
---@return boolean
function M.valid(range, exclusive)
    if exclusive then
        return range[1] < range[2]
    else
        return range[1] <= range[2]
    end
end

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
---@return render.md.Range?
function M.overlap(a, b, exclusive)
    ---@type render.md.Range
    local result = {
        math.max(a[1], b[1]),
        math.min(a[2], b[2]),
    }
    return M.valid(result, exclusive) and result or nil
end

---@param ranges render.md.Range[]
---@return render.md.Range[]
function M.coalesce(ranges)
    M.sort(ranges)
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

---@param ranges render.md.Range[]
function M.sort(ranges)
    table.sort(ranges, function(a, b)
        if a[1] ~= b[1] then
            return a[1] < b[1]
        else
            return a[2] < b[2]
        end
    end)
end

return M
