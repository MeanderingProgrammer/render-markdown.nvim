---@class render.md.Iter
local M = {}

---@class render.md.iter.List
M.list = {}

---@generic T, U
---@param values T[]
---@param f fun(value: T): U
---@return U[]
function M.list.map(values, f)
    local result = {}
    for _, value in ipairs(values) do
        result[#result + 1] = f(value)
    end
    return result
end

---@generic T
---@param values T[]
---@param f fun(value: T): integer
function M.list.sort(values, f)
    table.sort(values, function(a, b)
        return f(a) < f(b)
    end)
end

---@class render.md.iter.Table
M.table = {}

---@generic T
---@param values { [any]: T }
---@param f fun(value: T): boolean
---@return T[]
function M.table.filter(values, f)
    local result = {}
    for _, value in pairs(values) do
        if f(value) then
            result[#result + 1] = value
        end
    end
    return result
end

return M
