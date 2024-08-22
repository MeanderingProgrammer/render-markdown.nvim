local NodeInfo = require('render-markdown.node_info')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local str = require('render-markdown.str')

---@type table<string, string[]>
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
        logger.debug('executable not found', latex.converter)
        return {}
    end

    local info = NodeInfo.new(buf, root)
    logger.debug_node_info('latex', info)

    local expressions = cache[info.text]
    if expressions == nil then
        local raw_expression = vim.fn.system(latex.converter, info.text)
        expressions = str.split(raw_expression, '\n')
        for _ = 1, latex.top_pad do
            table.insert(expressions, 1, '')
        end
        for _ = 1, latex.bottom_pad do
            table.insert(expressions, '')
        end
        cache[info.text] = expressions
    end

    local latex_lines = vim.tbl_map(function(expression)
        return { { expression, latex.highlight } }
    end, expressions)

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
