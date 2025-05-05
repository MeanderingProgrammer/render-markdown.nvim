local Context = require('render-markdown.request.context')
local Marks = require('render-markdown.lib.marks')
local ts = require('render-markdown.core.ts')

---@class render.md.handler.buf.MarkdownInline
---@field private query vim.treesitter.Query
---@field private renders table<string, render.md.Render>
---@field private context render.md.request.Context
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.MarkdownInline
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.query = ts.parse(
        'markdown_inline',
        [[
            (code_span) @code

            ((inline) @highlight
                (#lua-match? @highlight "==[^=]+=="))

            [
                (email_autolink)
                (full_reference_link)
                (image)
                (inline_link)
                (uri_autolink)
            ] @link

            (shortcut_link) @shortcut
        ]]
    )
    self.renders = {
        code = require('render-markdown.render.inline.code'),
        highlight = require('render-markdown.render.inline.highlight'),
        link = require('render-markdown.render.inline.link'),
        shortcut = require('render-markdown.render.inline.shortcut'),
    }
    self.context = Context.get(buf)
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    local marks = Marks.new(self.context, true)
    self.context.view:nodes(root, self.query, function(capture, node)
        local render = self.renders[capture]
        assert(render ~= nil, 'unhandled inline capture: ' .. capture)
        render:execute(self.context, marks, node)
    end)
    return marks:get()
end

---@class render.md.handler.MarkdownInline: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):parse(ctx.root)
end

return M
