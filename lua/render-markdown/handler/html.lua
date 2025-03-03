local Context = require('render-markdown.core.context')
local Marks = require('render-markdown.lib.marks')
local state = require('render-markdown.state')
local ts = require('render-markdown.integ.ts')

---@class render.md.handler.buf.Html
---@field private config render.md.buffer.Config
---@field private context render.md.Context
---@field private marks render.md.Marks
---@field private query vim.treesitter.Query
---@field private renderers table<string, render.md.Renderer>
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Html
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.config = state.get(buf)
    self.context = Context.get(buf)
    self.marks = Marks.new(buf, true)
    self.query = ts.parse(
        'html',
        [[
            (comment) @comment
            (element) @tag
        ]]
    )
    self.renderers = {
        comment = require('render-markdown.render.html_comment'),
        tag = require('render-markdown.render.html_tag'),
    }
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    if self.context:skip(self.config.html) then
        return {}
    end
    self.context:query(root, self.query, function(capture, node)
        local renderer = self.renderers[capture]
        assert(renderer ~= nil, 'Unhandled html capture: ' .. capture)
        local render = renderer:new(self.marks, self.config, self.context, node)
        if render:setup() then
            render:render()
        end
    end)
    return self.marks:get()
end

---@class render.md.handler.Html: render.md.Handler
local M = {}

---@param ctx render.md.HandlerContext
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):parse(ctx.root)
end

return M
