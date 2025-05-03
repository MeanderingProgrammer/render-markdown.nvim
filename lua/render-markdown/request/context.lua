local Conceal = require('render-markdown.request.conceal')
local Env = require('render-markdown.lib.env')
local Str = require('render-markdown.lib.str')
local View = require('render-markdown.request.view')

---@class render.md.context.Offset
---@field col integer
---@field width integer

---@class render.md.request.Context
---@field private callouts table<integer, render.md.callout.Config>
---@field private checkboxes table<integer, render.md.checkbox.custom.Config>
---@field private offsets table<integer, render.md.context.Offset[]>
---@field buf integer
---@field win integer
---@field config render.md.main.Config
---@field mode string
---@field view render.md.request.View
---@field conceal render.md.request.Conceal
---@field last_heading? integer
local Context = {}
Context.__index = Context

---@param buf integer
---@param win integer
---@param config render.md.main.Config
---@param mode string
---@param view render.md.request.View
---@return render.md.request.Context
function Context.new(buf, win, config, mode, view)
    local self = setmetatable({}, Context)

    self.callouts = {}
    self.checkboxes = {}
    self.offsets = {}

    self.buf = buf
    self.win = win
    self.config = config
    self.mode = mode
    self.view = view

    self.conceal = Conceal.new(self)
    self.last_heading = nil

    return self
end

---@param config render.md.base.Config
---@return boolean
function Context:skip(config)
    -- Skip disabled config regardless of mode
    if not config.enabled then
        return true
    end
    -- Enabled config in top level modes should not be skipped
    if Env.mode.is(self.mode, self.config.render_modes) then
        return false
    end
    -- Enabled config in config modes should not be skipped
    return not Env.mode.is(self.mode, config.render_modes)
end

---@param row integer
---@return render.md.callout.Config?
function Context:get_callout(row)
    return self.callouts[row]
end

---@param row integer
---@param callout render.md.callout.Config
function Context:add_callout(row, callout)
    self.callouts[row] = callout
end

---@param row integer
---@return render.md.checkbox.custom.Config?
function Context:get_checkbox(row)
    return self.checkboxes[row]
end

---@param row integer
---@param checkbox render.md.checkbox.custom.Config
function Context:add_checkbox(row, checkbox)
    self.checkboxes[row] = checkbox
end

---@param node? render.md.Node
---@return integer
function Context:width(node)
    if not node then
        return 0
    end
    return Str.width(node.text) + self:get_offset(node) - self.conceal:get(node)
end

---@private
---@param node render.md.Node
---@return integer
function Context:get_offset(node)
    local result = 0
    local offsets = self.offsets[node.start_row] or {}
    for _, offset in ipairs(offsets) do
        if node.start_col <= offset.col and node.end_col > offset.col then
            result = result + offset.width
        end
    end
    return result
end

---@param row integer
---@param offset render.md.context.Offset
function Context:add_offset(row, offset)
    if offset.width <= 0 then
        return
    end
    if not self.offsets[row] then
        self.offsets[row] = {}
    end
    local offsets = self.offsets[row]
    offsets[#offsets + 1] = offset
end

---@param value number
---@param used integer
---@return integer
function Context:percent(value, used)
    if value <= 0 then
        return 0
    elseif value >= 1 then
        return value
    else
        local available = Env.win.width(self.win) - used
        return math.floor((available * value) + 0.5)
    end
end

---@class render.md.request.context.Manager
local M = {}

---@private
---@type table<integer, render.md.request.Context>
M.cache = {}

---@param buf integer
---@param win integer
---@return boolean
function M.contains(buf, win)
    local context = M.cache[buf]
    return context and context.view:contains(win) or false
end

---@param buf integer
---@param win integer
---@param config render.md.main.Config
---@param mode string
---@return render.md.request.Context
function M.start(buf, win, config, mode)
    local view = View.new(buf)
    local context = Context.new(buf, win, config, mode, view)
    M.cache[buf] = context
    return context
end

---@param buf integer
---@return render.md.request.Context
function M.get(buf)
    return assert(M.cache[buf], 'missing request context')
end

return M
