---@class render.md.Extmark
---@field private namespace integer
---@field private buf integer
---@field private mark render.md.Mark
---@field private id? integer
local Extmark = {}
Extmark.__index = Extmark

---@param namespace integer
---@param buf integer
---@param mark render.md.Mark
---@return render.md.Extmark
function Extmark.new(namespace, buf, mark)
    local self = setmetatable({}, Extmark)
    self.namespace = namespace
    self.buf = buf
    self.mark = mark
    self.id = nil
    return self
end

---@param config render.md.buffer.Config
---@param row? integer
function Extmark:render(config, row)
    if self:should_show(config.anti_conceal, row) then
        self:show()
    else
        self:hide()
    end
end

---@private
function Extmark:show()
    if self.id == nil then
        self.mark.opts.strict = false
        self.id = vim.api.nvim_buf_set_extmark(
            self.buf,
            self.namespace,
            self.mark.start_row,
            self.mark.start_col,
            self.mark.opts
        )
    end
end

---@private
function Extmark:hide()
    if self.id ~= nil then
        vim.api.nvim_buf_del_extmark(self.buf, self.namespace, self.id)
        self.id = nil
    end
end

---Render marks based on anti-conceal behavior and current row
---@private
---@param anti_conceal render.md.AntiConceal
---@param row? integer
---@return boolean
function Extmark:should_show(anti_conceal, row)
    -- Anti-conceal is not enabled -> all marks should be shown
    if not anti_conceal.enabled then
        return true
    end
    -- Row is not known means buffer is not active -> all marks should be shown
    if row == nil then
        return true
    end
    -- Mark is not concealable -> mark should always be shown
    if not self.mark.conceal then
        return true
    end
    -- Show mark if it is outside current row range
    local mark_row = self.mark.start_row
    return mark_row < row - anti_conceal.above or mark_row > row + anti_conceal.below
end

return Extmark
