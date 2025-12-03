local Context = require('render-markdown.request.context')
local Marks = require('render-markdown.lib.marks')
local ts = require('render-markdown.core.ts')

---@class render.md.handler.Html: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    -- stylua: ignore
    local query = ts.parse('html', [[
        (comment) @comment
        (element) @tag
    ]])
    ---@type table<string, render.md.Render>
    local renders = {
        comment = require('render-markdown.render.html.comment'),
        tag = require('render-markdown.render.html.tag'),
    }
    local context = Context.get(ctx.buf)
    if not context.config.html.enabled then
        return {}
    end
    local marks = Marks.new(context, true)
    context.view:nodes(ctx.root, query, function(capture, node)
        local render = renders[capture]
        assert(render, ('unhandled html capture: %s'):format(capture))
        render:execute(context, marks, node)
    end)
    return marks:get()
end

return M
