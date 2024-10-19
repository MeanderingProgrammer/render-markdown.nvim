---@class render.md.BufferState
---@field private timer uv_timer_t
---@field private running boolean
---@field private marks? render.md.Extmark[]
local BufferState = {}
BufferState.__index = BufferState

---@return render.md.BufferState
function BufferState.new()
    local self = setmetatable({}, BufferState)
    self.timer = (vim.uv or vim.loop).new_timer()
    self.running = false
    self.marks = nil
    return self
end

---@param ms integer
---@param callback fun()
function BufferState:debounce(ms, callback)
    self.timer:start(ms, 0, function()
        self.running = false
    end)
    if not self.running then
        self.running = true
        vim.schedule(callback)
    end
end

---@return boolean
function BufferState:has_marks()
    return self.marks ~= nil
end

---@return render.md.Extmark[]
function BufferState:get_marks()
    return self.marks or {}
end

---@param marks? render.md.Extmark[]
function BufferState:set_marks(marks)
    self.marks = marks
end

return BufferState
