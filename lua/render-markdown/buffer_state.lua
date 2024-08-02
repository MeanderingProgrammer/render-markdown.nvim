---@class render.md.BufferState
---@field private buf integer
---@field private timer uv_timer_t
---@field private running boolean
---@field state? 'default'|'rendered'
local BufferState = {}
BufferState.__index = BufferState

---@param buf integer
---@return render.md.BufferState
function BufferState.new(buf)
    local self = setmetatable({}, BufferState)
    self.buf = buf
    self.timer = (vim.uv or vim.loop).new_timer()
    self.running = false
    self.state = nil
    return self
end

---@param ms integer
---@param cb fun(buf: integer)
function BufferState:debounce(ms, cb)
    self.timer:start(ms, 0, function()
        self.running = false
    end)
    if not self.running then
        self.running = true
        vim.schedule_wrap(cb)(self.buf)
    end
end

return BufferState
