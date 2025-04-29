local Context = require('render-markdown.core.context')
local Marks = require('render-markdown.lib.marks')
local ts = require('render-markdown.integ.ts')

---@class render.md.handler.buf.Html
---@field private query vim.treesitter.Query
---@field private renderers table<string, render.md.Render>
---@field private context render.md.Context
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
    self.renderers = {
        comment = require('render-markdown.render.html_comment'),
        tag = require('render-markdown.render.html_tag'),
    }
    self.context = Context.get(buf)
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    if self.context:skip(self.context.config.html) then
        return {}
    end
    local marks = Marks.new(self.context, true)
    self.context:query(root, self.query, function(capture, node)
        local renderer = self.renderers[capture]
        assert(renderer ~= nil, 'unhandled html capture: ' .. capture)
        local render = renderer:new(self.context, marks, node)
        if render:setup() then
            render:render()
        end
    end)
    return marks:get()
end

---@class render.md.handler.Html: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):parse(ctx.root)
end

return M
