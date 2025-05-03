local Context = require('render-markdown.request.context')
local Iter = require('render-markdown.lib.iter')
local Marks = require('render-markdown.lib.marks')
local Node = require('render-markdown.lib.node')
local Str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')

---@class render.md.handler.Latex: render.md.Handler
local M = {}

---@private
---@type table<string, string>
M.cache = {}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    local context = Context.get(ctx.buf)
    local latex = context.config.latex
    if context:skip(latex) then
        return {}
    end
    if vim.fn.executable(latex.converter) ~= 1 then
        log.add('debug', 'executable not found', latex.converter)
        return {}
    end

    local node = Node.new(ctx.buf, ctx.root)
    log.node('latex', node)

    local raw_expression = M.cache[node.text]
    if not raw_expression then
        raw_expression = vim.fn.system(latex.converter, node.text)
        if vim.v.shell_error == 1 then
            log.add('error', latex.converter, raw_expression)
            raw_expression = 'error'
        end
        M.cache[node.text] = raw_expression
    end

    local expressions = {} ---@type string[]
    for _ = 1, latex.top_pad do
        expressions[#expressions + 1] = ''
    end
    for _, expression in ipairs(Str.split(raw_expression, '\n', true)) do
        expressions[#expressions + 1] = Str.pad(node.start_col) .. expression
    end
    for _ = 1, latex.bottom_pad do
        expressions[#expressions + 1] = ''
    end

    local lines = Iter.list.map(expressions, function(expression)
        return { { expression, latex.highlight } }
    end)

    local above = latex.position == 'above'
    local row = above and node.start_row or node.end_row

    local marks = Marks.new(context, true)
    marks:add(false, row, 0, {
        virt_lines = lines,
        virt_lines_above = above,
    })
    return marks:get()
end

return M
