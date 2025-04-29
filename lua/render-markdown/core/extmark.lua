---@class render.md.Extmark
---@field private id? integer
---@field private mark render.md.Mark
local Extmark = {}
Extmark.__index = Extmark

---@param mark render.md.Mark
---@return render.md.Extmark
function Extmark.new(mark)
    local self = setmetatable({}, Extmark)
    self.id = nil
    self.mark = mark
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
    local top = self.mark.start_row
    local bottom = self.mark.opts.end_row or top
    -- overlap for hl_eol should not include last line
    if self.mark.opts.hl_eol then
        bottom = bottom - 1
    end
    return range:overlaps(top, bottom)
end

---@param ns integer
---@param buf integer
function Extmark:show(ns, buf)
    if self.id then
        return
    end
    local mark = self.mark
    mark.opts.strict = false
    local ok, id = pcall(
        vim.api.nvim_buf_set_extmark,
        buf,
        ns,
        mark.start_row,
        mark.start_col,
        mark.opts
    )
    if ok then
        self.id = id
    else
        local Compat = require('render-markdown.lib.compat')
        Compat.release(('nvim_buf_set_extmark error (%s)'):format(id))
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
