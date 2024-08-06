local logger = require('render-markdown.logger')
local util = require('render-markdown.util')

---@class render.md.ListHelper
local M = {}

---@param marks render.md.Mark[]
---@param conceal boolean
---@param start_row integer
---@param start_col integer
---@param opts vim.api.keyset.set_extmark
---@return boolean
function M.add_mark(marks, conceal, start_row, start_col, opts)
    -- Inline extmarks require neovim >= 0.10.0
    if opts.virt_text_pos == 'inline' and not util.has_10 then
        return false
    end
    ---@type render.md.Mark
    local mark = {
        conceal = conceal,
        start_row = start_row,
        start_col = start_col,
        opts = opts,
    }
    logger.debug('mark', mark)
    table.insert(marks, mark)
    return true
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
