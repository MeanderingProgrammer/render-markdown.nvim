local Compat = require('render-markdown.lib.compat')

---@class render.md.Decorator
---@field private timer uv.uv_timer_t
---@field private running boolean
---@field private marks? render.md.Extmark[]
local Decorator = {}
Decorator.__index = Decorator

---@return render.md.Decorator
function Decorator.new()
    local self = setmetatable({}, Decorator)
    self.timer = assert(Compat.uv.new_timer())
    self.running = false
    self.marks = nil
    return self
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

---@return boolean
function Decorator:initial()
    return self.marks == nil
end

---@return render.md.Extmark[]
function Decorator:get()
    return self.marks or {}
end

---@param marks render.md.Extmark[]
function Decorator:set(marks)
    self.marks = marks
end

function Decorator:clear()
    self.marks = nil
end

return Decorator
