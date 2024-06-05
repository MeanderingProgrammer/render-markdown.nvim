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
    local converter = state.config.latex_converter
    if vim.fn.executable(converter) ~= 1 then
        logger.debug('Executable not found: ' .. converter)
        return
    end

    local value = vim.treesitter.get_node_text(root, buf)
    local start_row, start_col, end_row, end_col = root:range()
    logger.debug_node('latex', root, buf)

    local expressions = cache.expressions[value]
    if expressions == nil then
        local raw_expression = vim.fn.system(converter, value)
        local parsed_expressions = vim.split(vim.trim(raw_expression), '\n', { plain = true })
        expressions = vim.tbl_map(vim.trim, parsed_expressions)
        cache.expressions[value] = expressions
    end

    local virt_lines = vim.tbl_map(function(expression)
        return { { expression, state.config.highlights.latex } }
    end, expressions)
    vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
        end_row = end_row,
        end_col = end_col,
        virt_lines = virt_lines,
        virt_lines_above = true,
    })
end

return M
