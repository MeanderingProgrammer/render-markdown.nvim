local Context = require('render-markdown.core.context')
local List = require('render-markdown.lib.list')
local state = require('render-markdown.state')
local treesitter = require('render-markdown.core.treesitter')

---@class render.md.handler.buf.MarkdownInline
---@field private config render.md.buffer.Config
---@field private context render.md.Context
---@field private marks render.md.Marks
---@field private query vim.treesitter.Query
---@field private renderers table<string, render.md.Renderer>
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.MarkdownInline
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.config = state.get(buf)
    self.context = Context.get(buf)
    self.marks = List.new_marks(buf, true)
    self.query = treesitter.parse(
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
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    self.context:query(root, self.query, function(capture, node)
        local renderer = self.renderers[capture]
        assert(renderer ~= nil, 'Unhandled inline capture: ' .. capture)
        local render = renderer:new(self.marks, self.config, self.context, node)
        if render:setup() then
            render:render()
        end
    end)
    return self.marks:get()
end

---@class render.md.handler.MarkdownInline: render.md.Handler
local M = {}

---@param ctx render.md.HandlerContext
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):parse(ctx.root)
end

return M
