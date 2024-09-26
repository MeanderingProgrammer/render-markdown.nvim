local Iter = require('render-markdown.core.iter')
local NodeInfo = require('render-markdown.core.node_info')
local list = require('render-markdown.core.list')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')
local str = require('render-markdown.core.str')

---@type table<string, string>
local cache = {}

---@class render.md.handler.Latex: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
function M.parse(root, buf)
    local latex = state.latex
    if not latex.enabled then
        return {}
    end
    if vim.fn.executable(latex.converter) ~= 1 then
        log.add('debug', 'executable not found', latex.converter)
        return {}
    end

    local info = NodeInfo.new(buf, root)
    log.node_info('latex', info)

    local raw_expression = cache[info.text]
    if raw_expression == nil then
        raw_expression = vim.fn.system(latex.converter, info.text)
        cache[info.text] = raw_expression
    end

    local expressions = str.split(raw_expression, '\n')
    for i = 1, #expressions do
        expressions[i] = str.pad(info.start_col) .. expressions[i]
    end
    for _ = 1, latex.top_pad do
        table.insert(expressions, 1, '')
    end
    for _ = 1, latex.bottom_pad do
        table.insert(expressions, '')
    end

    local latex_lines = Iter.list.map(expressions, function(expression)
        return { { expression, latex.highlight } }
    end)

    local marks = list.new_marks()
    marks:add(false, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_lines = latex_lines,
        virt_lines_above = true,
    })
    return marks:get()
end

return M
