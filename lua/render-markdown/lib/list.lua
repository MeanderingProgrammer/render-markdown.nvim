---@class render.md.List
local M = {}

---@generic T
---@param values `T`|T[]
---@param index integer
---@return T|nil
function M.cycle(values, index)
    if type(values) == 'table' then
        if #values == 0 then
            return nil
        end
        return values[((index - 1) % #values) + 1]
    else
        return values
    end
end

---@generic T
---@param values `T`|T[]
---@param index integer
---@return T|nil
function M.clamp(values, index)
    if type(values) == 'table' then
        if #values == 0 then
            return nil
        else
            return values[math.min(index, #values)]
        end
    else
        return values
    end
end

return M
