local Compat = require('render-markdown.lib.compat')
local Context = require('render-markdown.core.context')
local Env = require('render-markdown.lib.env')
local Str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')

---@alias render.md.mark.Element boolean|render.md.Element

---@class render.md.Marks
---@field private context render.md.Context
---@field private ignore render.md.config.conceal.Ignore
---@field private inline boolean
---@field private marks render.md.Mark[]
local Marks = {}
Marks.__index = Marks

---@param buf integer
---@param inline boolean
---@return render.md.Marks
function Marks.new(buf, inline)
    local self = setmetatable({}, Marks)
    self.context = Context.get(buf)
    self.ignore = state.get(buf).anti_conceal.ignore
    self.inline = inline
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
---@return boolean
function Marks:start(element, node, opts)
    return self:add(element, node.start_row, node.start_col, opts)
end

---@param element render.md.mark.Element
---@param node? render.md.Node
---@param opts render.md.MarkOpts
---@param offset? Range4
---@return boolean
function Marks:over(element, node, opts, offset)
    if node == nil then
        return false
    end
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
    self:update(mark)
    self.marks[#self.marks + 1] = mark
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
    if opts.virt_text_pos == 'inline' and not Compat.has_10 then
        return false, "virt_text_pos = 'inline'", '0.10.0'
    end
    if opts.virt_text_repeat_linebreak ~= nil and not Compat.has_10 then
        return false, 'virt_text_repeat_linebreak', '0.10.0'
    end
    if opts.conceal_lines ~= nil and not Compat.has_11 then
        return false, 'conceal_lines', '0.11.0'
    end
    return true, '', ''
end

---@private
---@param mark render.md.Mark
function Marks:update(mark)
    if not self.inline then
        return
    end
    local row, start_col = mark.start_row, mark.start_col
    if mark.opts.conceal ~= nil then
        local end_col = assert(mark.opts.end_col)
        self.context.conceal:add(row, {
            start_col = start_col,
            end_col = end_col,
            width = end_col - start_col,
            character = mark.opts.conceal,
        })
    end
    if mark.opts.virt_text_pos == 'inline' then
        self.context:add_offset(row, {
            col = start_col,
            width = Str.line_width(mark.opts.virt_text),
        })
    end
end

return Marks
