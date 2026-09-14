local Extmark = require('render-markdown.lib.extmark')
local compat = require('render-markdown.lib.compat')
local replacements = require('render-markdown.lib.replacements')

---@class render.md.Decorator
---@field private buf integer
---@field private timer uv.uv_timer_t
---@field private running boolean
---@field private marks render.md.Extmark[]
---@field private generated render.md.Extmark[]
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
    self.generated = {}
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
    local result = {} ---@type render.md.Extmark[]
    vim.list_extend(result, self.marks)
    vim.list_extend(result, self.generated)
    return result
end

---@param marks render.md.Extmark[]
function Decorator:set(marks)
    self.marks = marks
    self.tick = self:get_tick()
    self.n = self.n + 1
end

---@param ns integer
function Decorator:clear(ns)
    for _, extmark in ipairs(self:get()) do
        extmark:hide(ns, self.buf)
    end
    self.generated = {}
end

---@param ns integer
---@param hide fun(extmark: render.md.Extmark): boolean
function Decorator:display(ns, hide)
    local visible = {} ---@type render.md.Mark[]
    for _, extmark in ipairs(self.marks) do
        if hide(extmark) then
            extmark:hide(ns, self.buf)
        else
            extmark:show(ns, self.buf)
            visible[#visible + 1] = extmark:get()
        end
    end

    local line_count = vim.api.nvim_buf_line_count(self.buf)
    local generated = replacements.resolve(visible, line_count)
    local current = {} ---@type render.md.Mark[]
    for _, extmark in ipairs(self.generated) do
        current[#current + 1] = extmark:get()
    end
    if vim.deep_equal(current, generated) then
        return
    end
    for _, extmark in ipairs(self.generated) do
        extmark:hide(ns, self.buf)
    end
    self.generated = {}
    for _, mark in ipairs(generated) do
        local extmark = Extmark.new(mark)
        extmark:show(ns, self.buf)
        self.generated[#self.generated + 1] = extmark
    end
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
