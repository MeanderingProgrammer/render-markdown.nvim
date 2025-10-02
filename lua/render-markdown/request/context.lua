local str = require('render-markdown.lib.str')

---@class render.md.request.Context
---@field buf integer
---@field win integer
---@field config render.md.buf.Config
---@field view render.md.request.View
---@field conceal render.md.request.Conceal
---@field callout render.md.request.Callout
---@field checkbox render.md.request.Checkbox
---@field latex render.md.request.Latex
---@field offset render.md.request.Offset
---@field used render.md.request.Used
local Context = {}
Context.__index = Context

---@param buf integer
---@param win integer
---@param config render.md.buf.Config
---@param view render.md.request.View
---@return render.md.request.Context
function Context.new(buf, win, config, view)
    local self = setmetatable({}, Context)
    self.buf = buf
    self.win = win
    self.config = config
    self.view = view
    self.conceal =
        require('render-markdown.request.conceal').new(buf, win, view)
    self.callout = require('render-markdown.request.callout').new()
    self.checkbox = require('render-markdown.request.checkbox').new()
    self.latex = require('render-markdown.request.latex').new()
    self.offset = require('render-markdown.request.offset').new()
    self.used = require('render-markdown.request.used').new()
    return self
end

---@param body? render.md.node.Body
---@return integer
function Context:width(body)
    if not body then
        return 0
    end
    return str.width(body.text) + self.offset:get(body) - self.conceal:get(body)
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
---@return render.md.request.Context?
function M.new(buf, win, config)
    local view = require('render-markdown.request.view').new(buf)
    local context = Context.new(buf, win, config, view)
    M.cache[buf] = context
    return context
end

---@param buf integer
---@return render.md.request.Context
function M.get(buf)
    return assert(M.cache[buf], 'missing request context')
end

return M
