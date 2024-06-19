local logger = require('render-markdown.logger')
local state = require('render-markdown.state')

---@class render.md.Cache
---@field expressions table<string, string[]>

---@type render.md.Cache
local cache = {
    expressions = {},
}

local M = {}

---@param namespace integer
---@param root TSNode
---@param buf integer
M.render = function(namespace, root, buf)
    if not state.config.latex_enabled then
        return
    end
    local converter = state.config.latex_converter
    if vim.fn.executable(converter) ~= 1 then
        logger.debug('Executable not found: ' .. converter)
    else
        logger.debug_node('latex', root, buf)
        M.render_node(namespace, buf, root, converter)
    end
end

---@param namespace integer
---@param buf integer
---@param node TSNode
---@param converter string
M.render_node = function(namespace, buf, node, converter)
    local highlights = state.config.highlights
    local value = vim.treesitter.get_node_text(node, buf)
    local start_row, start_col, end_row, end_col = node:range()

    local expressions = cache.expressions[value]
    if expressions == nil then
        local raw_expression = vim.fn.system(converter, value)
        local parsed_expressions = vim.split(vim.trim(raw_expression), '\n', { plain = true })
        expressions = vim.tbl_map(vim.trim, parsed_expressions)
        cache.expressions[value] = expressions
    end

    local latex_lines = vim.tbl_map(function(expression)
        return { { expression, highlights.latex } }
    end, expressions)
    vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
        end_row = end_row,
        end_col = end_col,
        virt_lines = latex_lines,
        virt_lines_above = true,
    })
end

return M
