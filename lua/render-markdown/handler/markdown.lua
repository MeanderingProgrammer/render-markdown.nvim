local Context = require('render-markdown.core.context')
local list = require('render-markdown.core.list')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')

---@class render.md.handler.buf.Markdown
---@field private marks render.md.Marks
---@field private config render.md.buffer.Config
---@field private context render.md.Context
---@field private renderers table<string, render.md.Renderer>
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Markdown
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.marks = list.new_marks()
    self.config = state.get(buf)
    self.context = Context.get(buf)
    self.renderers = {
        checkbox = require('render-markdown.render.checkbox'),
        code = require('render-markdown.render.code'),
        dash = require('render-markdown.render.dash'),
        heading = require('render-markdown.render.heading'),
        list_marker = require('render-markdown.render.list_marker'),
        quote = require('render-markdown.render.quote'),
        section = require('render-markdown.render.section'),
        table = require('render-markdown.render.table'),
    }
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    self.context:query(root, state.markdown_query, function(capture, info)
        local renderer = self.renderers[capture]
        if renderer ~= nil then
            local render = renderer:new(self.marks, self.config, self.context, info)
            if render:setup() then
                render:render()
            end
        else
            log.unhandled_capture('markdown', capture)
        end
    end)
    return self.marks:get()
end

---@class render.md.handler.Markdown: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
function M.parse(root, buf)
    return Handler.new(buf):parse(root)
end

return M
