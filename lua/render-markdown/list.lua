local logger = require('render-markdown.logger')

---@class render.md.ListHelper
local M = {}

---@param marks render.md.Mark[]
---@param new_mark? render.md.Mark
function M.add_mark(marks, new_mark)
    if new_mark ~= nil then
        logger.debug('mark', new_mark)
        table.insert(marks, new_mark)
    end
end

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
