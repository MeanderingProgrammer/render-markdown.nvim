---@class render.md.Range
---@field top integer
---@field bottom integer
local Range = {}
Range.__index = Range

---@param top integer
---@param bottom integer
---@return render.md.Range
function Range.new(top, bottom)
    local self = setmetatable({}, Range)
    self.top = top
    self.bottom = bottom
    return self
end

---@param a render.md.Range
---@param b render.md.Range
---@return boolean
function Range.__lt(a, b)
    if a.top ~= b.top then
        return a.top < b.top
    else
        return a.bottom < b.bottom
    end
end

---@param top integer
---@param bottom integer
---@return boolean
function Range:contains(top, bottom)
    return self.top <= top and self.bottom >= bottom
end

---@param top integer
---@param bottom integer
---@return boolean
function Range:overlaps(top, bottom)
    return top < self.bottom and bottom >= self.top
end

---@param ranges render.md.Range[]
---@return render.md.Range[]
function Range.coalesce(ranges)
    if #ranges < 2 then
        return ranges
    end
    table.sort(ranges)
    local result = { ranges[1] }
    for i = 2, #ranges do
        local range, current = ranges[i], result[#result]
        if range.top <= current.bottom + 1 then
            current.bottom = math.max(current.bottom, range.bottom)
        else
            table.insert(result, range)
        end
    end
    return result
end

return Range
