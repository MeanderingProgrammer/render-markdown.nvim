local Context = require('render-markdown.request.context')
local Marks = require('render-markdown.lib.marks')
local ts = require('render-markdown.core.ts')

---@class render.md.handler.buf.Html
---@field private query vim.treesitter.Query
---@field private renders table<string, render.md.Render>
---@field private context render.md.request.Context
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Html
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.query = ts.parse(
        'html',
        [[
            (comment) @comment
            (element) @tag
        ]]
    )
    self.renders = {
        comment = require('render-markdown.render.html.comment'),
        tag = require('render-markdown.render.html.tag'),
    }
    self.context = Context.get(buf)
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:run(root)
    if self.context:skip(self.context.config.html) then
        return {}
    end
    local marks = Marks.new(self.context, true)
    self.context.view:nodes(root, self.query, function(capture, node)
        local render = self.renders[capture]
        assert(render ~= nil, 'unhandled html capture: ' .. capture)
        render:execute(self.context, marks, node)
    end)
    return marks:get()
end

---@class render.md.handler.Html: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):run(ctx.root)
end

return M
