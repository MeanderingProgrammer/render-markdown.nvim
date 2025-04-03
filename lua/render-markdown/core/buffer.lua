local Compat = require('render-markdown.lib.compat')

---@class render.md.Buffer
---@field private buf integer
---@field private empty boolean
---@field private timer uv.uv_timer_t
---@field private running boolean
---@field private marks? render.md.Extmark[]
local Buffer = {}
Buffer.__index = Buffer

---@param buf integer
---@return render.md.Buffer
function Buffer.new(buf)
    local self = setmetatable({}, Buffer)
    self.buf = buf
    self.empty = true
    self.timer = assert(Compat.uv.new_timer())
    self.running = false
    self.marks = nil
    return self
end

---@return boolean
function Buffer:is_empty()
    if self.empty then
        if vim.api.nvim_buf_line_count(self.buf) > 1 then
            self.empty = false
        else
            local line = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)[1]
            self.empty = line == nil or line == ''
        end
    end
    return self.empty
end

---@param ms integer
---@param callback fun()
function Buffer:debounce(ms, callback)
    self.timer:start(ms, 0, function()
        self.running = false
    end)
    if not self.running then
        self.running = true
        vim.schedule(callback)
    end
end

---@return boolean
function Buffer:has_marks()
    return self.marks ~= nil
end

---@return render.md.Extmark[]
function Buffer:get_marks()
    return self.marks or {}
end

---@param marks? render.md.Extmark[]
function Buffer:set_marks(marks)
    self.marks = marks
end

return Buffer
