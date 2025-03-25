local Context = require('render-markdown.core.context')
local Env = require('render-markdown.lib.env')
local Str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')

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

---@param element render.md.mark.Element
---@param node render.md.Node
---@param opts render.md.MarkOpts
---@param offset? Range4
---@return boolean
function Marks:add_over(element, node, opts, offset)
    offset = offset or { 0, 0, 0, 0 }
    opts.end_row = node.end_row + offset[3]
    opts.end_col = node.end_col + offset[4]
    return self:add(element, node.start_row + offset[1], node.start_col + offset[2], opts)
end

---@param element render.md.mark.Element
---@param start_row integer
---@param start_col integer
---@param opts render.md.MarkOpts
---@return boolean
function Marks:add(element, start_row, start_col, opts)
    ---@type render.md.Mark
    local mark = {
        conceal = self:conceal(element),
        start_row = start_row,
        start_col = start_col,
        opts = opts,
    }
    local valid, feature, min_version = self:validate(opts)
    if not valid then
        log.add('error', 'mark', string.format('%s requires neovim >= %s', feature, min_version), mark)
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
---@param element render.md.mark.Element
---@return boolean
function Marks:conceal(element)
    if type(element) == 'boolean' then
        return element
    end
    local modes = self.ignore[element]
    if modes == nil then
        return true
    else
        return not Env.mode.is(self.context.mode, modes)
    end
end

---@private
---@param opts render.md.MarkOpts
---@return boolean, string, string
function Marks:validate(opts)
    if opts.virt_text_pos == 'inline' and not Env.has_10 then
        return false, "virt_text_pos = 'inline'", '0.10.0'
    end
    if opts.virt_text_repeat_linebreak ~= nil and not Env.has_10 then
        return false, 'virt_text_repeat_linebreak', '0.10.0'
    end
    -- TODO(0.11): remove
    ---@diagnostic disable-next-line: undefined-field
    if opts.conceal_lines ~= nil and not Env.has_11 then
        return false, 'conceal_lines', '0.11.0'
    end
    return true, '', ''
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
        local width = Str.line_width(mark.opts.virt_text)
        self.context:add_offset(row, start_col, end_col, width)
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
