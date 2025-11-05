---@class render.md.List
local M = {}

---@generic T
---@param values `T`|T[]
---@return T[]
function M.ensure(values)
    return type(values) == 'table' and values or { values }
end

---@generic T
---@param values `T`|T[]
---@param index integer
---@return T|nil
function M.cycle(values, index)
    values = M.ensure(values)
    if #values == 0 then
        return nil
    end
    return values[((index - 1) % #values) + 1]
end

---@generic T
---@param values `T`|T[]
---@param index integer
---@return T|nil
function M.clamp(values, index)
    values = M.ensure(values)
    if #values == 0 then
        return nil
    end
    return values[math.min(index, #values)]
end

return M
