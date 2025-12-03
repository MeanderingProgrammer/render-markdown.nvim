local Context = require('render-markdown.request.context')
local Marks = require('render-markdown.lib.marks')
local ts = require('render-markdown.core.ts')

---@class render.md.handler.Markdown: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    -- stylua: ignore
    local query = ts.parse('markdown', [[
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
    ]])
    ---@type table<string, render.md.Render>
    local renders = {
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
    local context = Context.get(ctx.buf)
    local marks = Marks.new(context, false)
    context.view:nodes(ctx.root, query, function(capture, node)
        local render = renders[capture]
        assert(render, ('unhandled markdown capture: %s'):format(capture))
        render:execute(context, marks, node)
    end)
    return marks:get()
end

return M
