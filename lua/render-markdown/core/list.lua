local log = require('render-markdown.core.log')
local util = require('render-markdown.core.util')

---@class render.md.Marks
---@field private mode string
---@field private ignore render.md.config.conceal.Ignore
---@field private marks render.md.Mark[]
local Marks = {}
Marks.__index = Marks

---@param mode? string
---@param ignore? render.md.config.conceal.Ignore
---@return render.md.Marks
function Marks.new(mode, ignore)
    local self = setmetatable({}, Marks)
    self.mode = mode or util.mode()
    self.ignore = ignore or {}
    self.marks = {}
    return self
end

---@return render.md.Mark[]
function Marks:get()
    return self.marks
end

---@param element boolean|render.md.Element
---@param start_row integer
---@param start_col integer
---@param opts vim.api.keyset.set_extmark
---@return boolean
function Marks:add(element, start_row, start_col, opts)
    ---@type render.md.Mark
    local mark = {
        conceal = self:conceal(element),
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

---@private
---@param element boolean|render.md.Element
---@return boolean
function Marks:conceal(element)
    if type(element) == 'boolean' then
        return element
    end
    local value = self.ignore[element]
    if value == nil then
        return true
    elseif type(value) == 'boolean' then
        return not value
    else
        return not vim.tbl_contains(value, self.mode)
    end
end

---@class render.md.ListHelper
local M = {}

M.new_marks = Marks.new

---@generic T
---@param values T[]
---@param index integer
---@return T|nil
function M.cycle(values, index)
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
