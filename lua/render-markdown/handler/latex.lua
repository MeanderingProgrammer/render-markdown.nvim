local state = require('render-markdown.state')

---@class Cache
---@field expressions table<string,string[]>

---@type Cache
local cache = {
    expressions = {},
}

local M = {}

---@param namespace number
---@param root TSNode
M.render = function(namespace, root)
    if vim.fn.executable('latex2text') ~= 1 then
        return
    end

    local latex = vim.treesitter.get_node_text(root, 0)
    local cached_expressions = cache.expressions[latex]
    if cached_expressions == nil then
        local raw_expression = vim.fn.system('latex2text', latex)
        local expressions = vim.split(vim.trim(raw_expression), '\n', { plain = true })
        cached_expressions = vim.tbl_map(vim.trim, expressions)
        cache.expressions[latex] = cached_expressions
    end

    local start_row, start_col, end_row, end_col = root:range()
    local virt_lines = vim.tbl_map(function(expression)
        return { { expression, state.config.highlights.latex } }
    end, cached_expressions)
    vim.api.nvim_buf_set_extmark(0, namespace, start_row, start_col, {
        end_row = end_row,
        end_col = end_col,
        virt_lines = virt_lines,
        virt_lines_above = true,
    })
end

return M
