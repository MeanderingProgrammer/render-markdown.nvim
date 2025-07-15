local compat = require('render-markdown.lib.compat')

---@class render.md.Decorator
---@field private buf integer
---@field private timer uv.uv_timer_t
---@field private running boolean
---@field private marks render.md.Extmark[]
---@field private tick integer?
---@field n integer
local Decorator = {}
Decorator.__index = Decorator

---@param buf integer
---@return render.md.Decorator
function Decorator.new(buf)
    local self = setmetatable({}, Decorator)
    self.buf = buf
    self.timer = assert(compat.uv.new_timer())
    self.running = false
    self.marks = {}
    self.tick = nil
    self.n = 0
    return self
end

---@return boolean
function Decorator:initial()
    return self.tick == nil
end

---@return boolean
function Decorator:changed()
    return self.tick ~= self:get_tick()
end

---@return render.md.Extmark[]
function Decorator:get()
    return self.marks
end

---@param marks render.md.Extmark[]
function Decorator:set(marks)
    self.marks = marks
    self.tick = self:get_tick()
    self.n = self.n + 1
end

---@param debounce boolean
---@param ms integer
---@param callback fun()
function Decorator:schedule(debounce, ms, callback)
    if debounce and ms > 0 then
        self.timer:start(ms, 0, function()
            self.running = false
        end)
        if not self.running then
            self.running = true
            vim.schedule(callback)
        end
    else
        vim.schedule(callback)
    end
end

---@private
---@return integer
function Decorator:get_tick()
    return vim.api.nvim_buf_get_changedtick(self.buf)
end

return Decorator
