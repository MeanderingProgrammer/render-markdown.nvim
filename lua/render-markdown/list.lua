local M = {}

---@param values string[]
---@param index integer
---@return string
function M.cycle(values, index)
    return values[((index - 1) % #values) + 1]
end

---@param values string[]
---@param index integer
---@return string
function M.clamp_last(values, index)
    return values[math.min(index, #values)]
end

return M
