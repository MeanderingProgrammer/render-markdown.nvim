local Compat = require('render-markdown.lib.compat')
local Env = require('render-markdown.lib.env')
local Str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')

---@class (exact) render.md.Mark
---@field conceal boolean
---@field start_row integer
---@field start_col integer
---@field opts render.md.mark.Opts

---@class render.md.mark.Opts: vim.api.keyset.set_extmark
---@field hl_mode? 'replace'|'combine'|'blend'
---@field virt_text? render.md.mark.Line
---@field virt_text_pos? 'eol'|'inline'|'overlay'
---@field virt_lines? render.md.mark.Line[]

---@alias render.md.mark.Line render.md.mark.Text[]

---@class (exact) render.md.mark.Text
---@field [1] string text
---@field [2] string|string[] highlights

---@alias render.md.mark.Element boolean|render.md.Element

---@class render.md.Marks
---@field private context render.md.Context
---@field private ignore render.md.conceal.Ignore
---@field private inline boolean
---@field private marks render.md.Mark[]
local Marks = {}
Marks.__index = Marks

---@param context render.md.Context
---@param inline boolean
---@return render.md.Marks
function Marks.new(context, inline)
    local self = setmetatable({}, Marks)
    self.context = context
    self.ignore = context.config.anti_conceal.ignore
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
---@param opts render.md.mark.Opts
---@return boolean
function Marks:start(element, node, opts)
    return self:add(element, node.start_row, node.start_col, opts)
end

---@param element render.md.mark.Element
---@param node? render.md.Node
---@param opts render.md.mark.Opts
---@param offset? Range4
---@return boolean
function Marks:over(element, node, opts, offset)
    if node == nil then
        return false
    end
    offset = offset or { 0, 0, 0, 0 }
    local start_row = node.start_row + offset[1]
    local start_col = node.start_col + offset[2]
    opts.end_row = node.end_row + offset[3]
    opts.end_col = node.end_col + offset[4]
    return self:add(element, start_row, start_col, opts)
end

---@param element render.md.mark.Element
---@param start_row integer
---@param start_col integer
---@param opts render.md.mark.Opts
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
        local message = feature .. ' requires neovim >= ' .. min_version
        log.add('error', 'mark', message, mark)
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
---@param opts render.md.mark.Opts
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
        local end_col = assert(mark.opts.end_col, 'conceal requires end_col')
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
