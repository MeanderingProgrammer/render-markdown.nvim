---@class render.md.ListHelper
local M = {}

---@param values render.md.Mark[]
---@param value? render.md.Mark
function M.add(values, value)
    if value ~= nil then
        table.insert(values, value)
    end
end

---@param values string[]
---@param index integer
---@return string
function M.cycle(values, index)
    return values[((index - 1) % #values) + 1]
end

---@param values string[]
---@param index integer
---@return string
function M.clamp(values, index)
    return values[math.min(index, #values)]
end

---@param values string[]
---@return string
function M.first(values)
    return values[1]
end

---@param values string[]
---@return string
function M.last(values)
    return values[#values]
end

return M
