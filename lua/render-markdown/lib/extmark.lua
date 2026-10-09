local interval = require('render-markdown.lib.interval')

---@class render.md.Extmark
---@field private id? integer
---@field private kind? string
---@field private mark render.md.Mark
---@field private range render.md.Range
local Extmark = {}
Extmark.__index = Extmark

---@param mark render.md.Mark
---@return render.md.Extmark
function Extmark.new(mark)
    local self = setmetatable({}, Extmark)
    self.id = nil
    self.mark = mark
    local top = mark.start_row
    local bottom = mark.opts.end_row or top
    -- hl_eol should not include last line
    if mark.opts.hl_eol then
        bottom = bottom - 1
    end
    self.range = { top, bottom }
    return self
end

---@return render.md.Mark
function Extmark:get()
    return self.mark
end

---@param range? render.md.Range
---@return boolean
function Extmark:overlaps(range)
    if not range then
        return false
    end
    return interval.overlap(self.range, range) ~= nil
end

---kind distinguishes a normal show from the cursor-row presentation.
---The extmark is recreated when kind changes so conceal_lines can be added
---or removed as the cursor moves.
---@param ns integer
---@param buf integer
---@param kind? string
---@param opts? render.md.mark.Opts
---@param col? integer
function Extmark:show(ns, buf, kind, opts, col)
    kind = kind or 'default'
    if self.id then
        if self.kind == kind then
            return
        end
        self:hide(ns, buf)
    end
    self.kind = kind
    local mark = self.mark
    local applied = opts or mark.opts
    applied.strict = false
    local ok, id = pcall(
        vim.api.nvim_buf_set_extmark,
        buf,
        ns,
        mark.start_row,
        col or mark.start_col,
        applied
    )
    if ok then
        self.id = id
    else
        local compat = require('render-markdown.lib.compat')
        compat.release(('nvim_buf_set_extmark error (%s)'):format(id))
    end
end

---@param ns integer
---@param buf integer
function Extmark:hide(ns, buf)
    if not self.id then
        return
    end
    vim.api.nvim_buf_del_extmark(buf, ns, self.id)
    self.id = nil
end

return Extmark
