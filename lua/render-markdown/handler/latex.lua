local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local ts = require('render-markdown.ts')

---@class render.md.LatexCache
---@field expressions table<string, string[]>

---@type render.md.LatexCache
local cache = {
    expressions = {},
}

---@class render.md.handler.Latex: render.md.Handler
local M = {}

---@param namespace integer
---@param root TSNode
---@param buf integer
M.render = function(namespace, root, buf)
    local latex = state.config.latex
    if not latex.enabled then
        return
    end
    if vim.fn.executable(latex.converter) ~= 1 then
        logger.debug('Executable not found: ' .. latex.converter)
        return
    end

    local info = ts.info(root, buf)
    logger.debug_node_info('latex', info)

    local expressions = cache.expressions[info.text]
    if expressions == nil then
        local raw_expression = vim.fn.system(latex.converter, info.text)
        local parsed_expressions = vim.split(vim.trim(raw_expression), '\n', { plain = true })
        expressions = vim.tbl_map(vim.trim, parsed_expressions)
        cache.expressions[info.text] = expressions
    end

    local latex_lines = vim.tbl_map(function(expression)
        return { { expression, latex.highlight } }
    end, expressions)
    vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_lines = latex_lines,
        virt_lines_above = true,
    })
end

return M
