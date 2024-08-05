---@class render.md.ListHelper
local M = {}

---@param values string[]
---@param index integer
---@return string?
function M.cycle(values, index)
    if #values == 0 then
        return nil
    end
    return values[((index - 1) % #values) + 1]
end

---@param values string[]
---@param index integer
---@return string
function M.clamp(values, index)
    assert(#values >= 1, 'Must have at least one value')
    return values[math.min(index, #values)]
end

return M
