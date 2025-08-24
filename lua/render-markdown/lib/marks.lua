local compat = require('render-markdown.lib.compat')
local log = require('render-markdown.core.log')
local str = require('render-markdown.lib.str')

---@class (exact) render.md.Mark
---@field modes? render.md.Modes
---@field conceal render.md.mark.Conceal
---@field start_row integer
---@field start_col integer
---@field opts render.md.mark.Opts

---@alias render.md.mark.Conceal boolean|render.md.Element

---@class render.md.mark.Opts: vim.api.keyset.set_extmark
---@field hl_mode? 'replace'|'combine'|'blend'
---@field virt_text? render.md.mark.Line
---@field virt_text_pos? 'eol'|'inline'|'overlay'
---@field virt_lines? render.md.mark.Line[]

---@alias render.md.mark.Line render.md.mark.Text[]

---@class (exact) render.md.mark.Text
---@field [1] string text
---@field [2] render.md.mark.Hl highlight

---@alias render.md.mark.Hl string|string[]

---@class render.md.Marks
---@field private context render.md.request.Context
---@field private update boolean
---@field private marks render.md.Mark[]
local Marks = {}
Marks.__index = Marks

---@param context render.md.request.Context
---@param update boolean
---@return render.md.Marks
function Marks.new(context, update)
    local self = setmetatable({}, Marks)
    self.context = context
    self.update = update
    self.marks = {}
    return self
end

---@return render.md.Mark[]
function Marks:get()
    return self.marks
end

---@param config render.md.base.Config
---@param conceal render.md.mark.Conceal
---@param node render.md.Node
---@param opts render.md.mark.Opts
---@return boolean
function Marks:start(config, conceal, node, opts)
    return self:add(config, conceal, node.start_row, node.start_col, opts)
end

---@param config render.md.base.Config
---@param conceal render.md.mark.Conceal
---@param node? render.md.Node
---@param opts render.md.mark.Opts
---@param offset? Range4
---@return boolean
function Marks:over(config, conceal, node, opts, offset)
    if not node then
        return false
    end
    offset = offset or { 0, 0, 0, 0 }
    local start_row = node.start_row + offset[1]
    local start_col = node.start_col + offset[2]
    opts.end_row = node.end_row + offset[3]
    opts.end_col = node.end_col + offset[4]
    return self:add(config, conceal, start_row, start_col, opts)
end

---@param config render.md.base.Config
---@param conceal render.md.mark.Conceal
---@param start_row integer
---@param start_col integer
---@param opts render.md.mark.Opts
---@return boolean
function Marks:add(config, conceal, start_row, start_col, opts)
    ---@type render.md.Mark
    local mark = {
        modes = config.render_modes,
        conceal = conceal,
        start_row = start_row,
        start_col = start_col,
        opts = opts,
    }
    local valid, feature, min_version = self:validate(mark.opts)
    if not valid then
        local message = feature .. ' requires neovim >= ' .. min_version
        log.add('error', 'Mark', message, mark)
        return false
    end
    log.add('trace', 'Mark', mark)
    if self.update then
        self:run_update(mark)
    end
    self.marks[#self.marks + 1] = mark
    return true
end

---@private
---@param opts render.md.mark.Opts
---@return boolean, string, string
function Marks:validate(opts)
    if opts.virt_text_pos == 'inline' and not compat.has_10 then
        return false, "virt_text_pos = 'inline'", '0.10.0'
    end
    if opts.virt_text_repeat_linebreak and not compat.has_10 then
        return false, 'virt_text_repeat_linebreak', '0.10.0'
    end
    if opts.conceal_lines and not compat.has_11 then
        return false, 'conceal_lines', '0.11.0'
    end
    return true, '', ''
end

---@private
---@param mark render.md.Mark
function Marks:run_update(mark)
    local row, start_col = mark.start_row, mark.start_col
    if mark.opts.conceal then
        local end_col = assert(mark.opts.end_col, 'conceal requires end_col')
        self.context.conceal:add(row, {
            col = { start_col, end_col },
            width = end_col - start_col,
            character = mark.opts.conceal,
        })
    end
    if mark.opts.virt_text_pos == 'inline' then
        self.context.offset:add(row, {
            col = start_col,
            width = str.line_width(mark.opts.virt_text),
        })
    end
end

return Marks
