---@class render.md.Extmark
---@field private namespace integer
---@field private buf integer
---@field private id? integer
---@field mark render.md.Mark
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
    self.id = nil
    self.mark = mark
    return self
end

---@param row integer
---@return boolean
function Extmark:overlaps(row)
    local start_row = self.mark.start_row
    local end_row = self.mark.opts.end_row or start_row
    if start_row == end_row then
        end_row = end_row + 1
    end
    return not (start_row > row or end_row <= row)
end

---@param hidden Range2?
function Extmark:render(hidden)
    if self:should_show(hidden) then
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

---@private
---@param hidden Range2?
---@return boolean
function Extmark:should_show(hidden)
    if hidden == nil or not self.mark.conceal then
        return true
    end
    -- Show mark if it is outside hidden range
    local row = self.mark.start_row
    return row < hidden[1] or row > hidden[2]
end

return Extmark
