local Context = require('render-markdown.core.context')
local Str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')
local util = require('render-markdown.core.util')

---@class render.md.Marks
---@field private context render.md.Context
---@field private ignore render.md.config.conceal.Ignore
---@field private update boolean
---@field private marks render.md.Mark[]
local Marks = {}
Marks.__index = Marks

---@param buf integer
---@param update boolean
---@return render.md.Marks
function Marks.new(buf, update)
    local self = setmetatable({}, Marks)
    self.context = Context.get(buf)
    self.ignore = state.get(buf).anti_conceal.ignore
    self.update = update
    self.marks = {}
    return self
end

---@return render.md.Mark[]
function Marks:get()
    return self.marks
end

---@param element boolean|render.md.Element
---@param node render.md.Node
---@param opts vim.api.keyset.set_extmark
---@param offset? Range4
---@return boolean
function Marks:add_over(element, node, opts, offset)
    offset = offset or { 0, 0, 0, 0 }
    opts.end_row = node.end_row + offset[3]
    opts.end_col = node.end_col + offset[4]
    return self:add(element, node.start_row + offset[1], node.start_col + offset[2], opts)
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
    if self.update then
        self:update_context(mark)
    end
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
    local modes = self.ignore[element]
    if modes == nil then
        return true
    else
        return not util.in_modes(modes, self.context.mode)
    end
end

---@private
---@param mark render.md.Mark
function Marks:update_context(mark)
    local row, start_col = mark.start_row, mark.start_col
    local end_col = mark.opts.end_col or start_col
    if mark.opts.conceal ~= nil then
        self.context.conceal:add(row, {
            start_col = start_col,
            end_col = end_col,
            width = end_col - start_col,
            character = mark.opts.conceal,
        })
    end
    if mark.opts.virt_text_pos == 'inline' then
        local amount = 0
        for _, text in ipairs(mark.opts.virt_text or {}) do
            amount = amount + Str.width(text[1])
        end
        self.context:add_offset(row, start_col, end_col, amount)
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
