local Callout = require('render-markdown.request.callout')
local Checkbox = require('render-markdown.request.checkbox')
local Conceal = require('render-markdown.request.conceal')
local Offset = require('render-markdown.request.offset')
local Used = require('render-markdown.request.used')
local View = require('render-markdown.request.view')
local env = require('render-markdown.lib.env')
local str = require('render-markdown.lib.str')

---@class render.md.request.Context
---@field buf integer
---@field win integer
---@field config render.md.buf.Config
---@field mode string
---@field view render.md.request.View
---@field conceal render.md.request.Conceal
---@field callout render.md.request.Callout
---@field checkbox render.md.request.Checkbox
---@field offset render.md.request.Offset
---@field used render.md.request.Used
local Context = {}
Context.__index = Context

---@param buf integer
---@param win integer
---@param config render.md.buf.Config
---@param mode string
---@param view render.md.request.View
---@return render.md.request.Context
function Context.new(buf, win, config, mode, view)
    local self = setmetatable({}, Context)
    self.buf = buf
    self.win = win
    self.config = config
    self.mode = mode
    self.view = view
    self.conceal = Conceal.new(buf, win, view)
    self.callout = Callout.new()
    self.checkbox = Checkbox.new()
    self.offset = Offset.new()
    self.used = Used.new()
    return self
end

---@param config render.md.base.Config
---@return boolean
function Context:skip(config)
    -- skip disabled config regardless of mode
    if not config.enabled then
        return true
    end
    -- enabled config in top level modes should not be skipped
    if env.mode.is(self.mode, self.config.render_modes) then
        return false
    end
    -- enabled config in config modes should not be skipped
    return not env.mode.is(self.mode, config.render_modes)
end

---@param node? render.md.Node
---@return integer
function Context:width(node)
    if not node then
        return 0
    end
    return str.width(node.text) + self.offset:get(node) - self.conceal:get(node)
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
---@param config render.md.buf.Config
---@param mode string
---@return render.md.request.Context
function M.new(buf, win, config, mode)
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
