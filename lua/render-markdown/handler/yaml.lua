local Context = require('render-markdown.request.context')
local Marks = require('render-markdown.lib.marks')
local ts = require('render-markdown.core.ts')

---@class render.md.handler.Yaml: render.md.Handler
local M = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    local query = ts.parse(
        'yaml',
        [[
            (block_sequence_item) @bullet

            ((double_quote_scalar) @link
                (#lua-match? @link "^\"%[%[.+%]%]\"$"))
        ]]
    )
    ---@type table<string, render.md.Render>
    local renders = {
        bullet = require('render-markdown.render.yaml.bullet'),
        link = require('render-markdown.render.common.wiki'),
    }
    local context = Context.get(ctx.buf)
    if not context.config.yaml.enabled then
        return {}
    end
    local marks = Marks.new(context, true)
    context.view:nodes(ctx.root, query, function(capture, node)
        local render = renders[capture]
        assert(render, ('unhandled yaml capture: %s'):format(capture))
        render:execute(context, marks, node)
    end)
    return marks:get()
end

return M
