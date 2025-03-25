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
        table.insert(result, f(value))
    end
    return result
end

---@class render.md.iter.Table
M.table = {}

---@generic V
---@param values table<any, V>
---@param f fun(value: V): boolean
---@return V[]
function M.table.filter(values, f)
    local result = {}
    for _, value in pairs(values) do
        if f(value) then
            table.insert(result, value)
        end
    end
    return result
end

return M
