local Context = require('render-markdown.core.context')
local Marks = require('render-markdown.lib.marks')
local ts = require('render-markdown.integ.ts')

---@class render.md.handler.buf.MarkdownInline
---@field private query vim.treesitter.Query
---@field private renderers table<string, render.md.Render>
---@field private context render.md.Context
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.MarkdownInline
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.query = ts.parse(
        'markdown_inline',
        [[
            (code_span) @code_inline

            (shortcut_link) @shortcut

            [
                (email_autolink)
                (full_reference_link)
                (image)
                (inline_link)
                (uri_autolink)
            ] @link

            ((inline) @inline_highlight
                (#lua-match? @inline_highlight "==[^=]+=="))
        ]]
    )
    self.renderers = {
        code_inline = require('render-markdown.render.code_inline'),
        inline_highlight = require('render-markdown.render.inline_highlight'),
        link = require('render-markdown.render.link'),
        shortcut = require('render-markdown.render.shortcut'),
    }
    self.context = Context.get(buf)
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    local marks = Marks.new(self.context, true)
    self.context:query(root, self.query, function(capture, node)
        local renderer = self.renderers[capture]
        assert(renderer ~= nil, 'Unhandled inline capture: ' .. capture)
        local render = renderer:new(self.context, marks, node)
        if render:setup() then
            render:render()
        end
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
