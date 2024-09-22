local log = require('render-markdown.core.log')
local util = require('render-markdown.core.util')

---@class render.md.Marks
---@field private marks render.md.Mark[]
local Marks = {}
Marks.__index = Marks

---@return render.md.Marks
function Marks.new()
    local self = setmetatable({}, Marks)
    self.marks = {}
    return self
end

---@return render.md.Mark[]
function Marks:get()
    return self.marks
end

---@param conceal boolean
---@param start_row integer
---@param start_col integer
---@param opts vim.api.keyset.set_extmark
---@return boolean
function Marks:add(conceal, start_row, start_col, opts)
    ---@type render.md.Mark
    local mark = {
        conceal = conceal,
        start_row = start_row,
        start_col = start_col,
        opts = opts,
    }
    if opts.virt_text_pos == 'inline' and not util.has_10 then
        log.add('error', 'inline marks require neovim >= 0.10.0', mark)
        return false
    end
    if opts.virt_text_repeat_linebreak ~= nil and not util.has_10 then
        log.add('error', 'repeat linebreak marks require neovim >= 0.10.0', mark)
        return false
    end
    log.add('debug', 'mark', mark)
    table.insert(self.marks, mark)
    return true
end

---@class render.md.ListHelper
local M = {}

---@return render.md.Marks
function M.new_marks()
    return Marks.new()
end

---@generic T
---@param values T[]
---@param index integer
---@return T?
function M.cycle(values, index)
    if #values == 0 then
        return nil
    end
    return values[((index - 1) % #values) + 1]
end

---@generic T
---@param values T[]
---@param index integer
---@return T
function M.clamp(values, index)
    assert(#values >= 1, 'Must have at least one value')
    return values[math.min(index, #values)]
end

return M
