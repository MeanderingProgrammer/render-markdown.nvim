local Context = require('render-markdown.request.context')
local Marks = require('render-markdown.lib.marks')
local ts = require('render-markdown.core.ts')

---@class render.md.handler.buf.Markdown
---@field private query vim.treesitter.Query
---@field private renders table<string, render.md.Render>
---@field private context render.md.request.Context
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Markdown
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.query = ts.parse(
        'markdown',
        [[
            (fenced_code_block) @code

            [
                (thematic_break)
                (minus_metadata)
                (plus_metadata)
            ] @dash

            (document) @document

            [
                (atx_heading)
                (setext_heading)
            ] @heading

            (list_item) @list

            (section (paragraph) @paragraph)

            (block_quote) @quote

            (section) @section

            (pipe_table) @table
        ]]
    )
    self.renders = {
        code = require('render-markdown.render.markdown.code'),
        dash = require('render-markdown.render.markdown.dash'),
        document = require('render-markdown.render.markdown.document'),
        heading = require('render-markdown.render.markdown.heading'),
        list = require('render-markdown.render.markdown.list'),
        paragraph = require('render-markdown.render.markdown.paragraph'),
        quote = require('render-markdown.render.markdown.quote'),
        section = require('render-markdown.render.markdown.section'),
        table = require('render-markdown.render.markdown.table'),
    }
    self.context = Context.get(buf)
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    local marks = Marks.new(self.context, false)
    self.context.view:nodes(root, self.query, function(capture, node)
        local render = self.renders[capture]
        assert(render ~= nil, 'unhandled markdown capture: ' .. capture)
        render:execute(self.context, marks, node)
    end)
    return marks:get()
end

---@class render.md.handler.Markdown: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    return Handler.new(ctx.buf):parse(ctx.root)
end

return M
