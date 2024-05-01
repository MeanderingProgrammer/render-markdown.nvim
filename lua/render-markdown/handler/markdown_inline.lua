local logger = require('render-markdown.logger')
local state = require('render-markdown.state')

local M = {}

---@param namespace number
---@param root TSNode
M.render = function(namespace, root)
    local highlights = state.config.highlights
    ---@diagnostic disable-next-line: missing-parameter
    for id, node in state.inline_query:iter_captures(root, 0) do
        local capture = state.inline_query.captures[id]
        local start_row, start_col, end_row, end_col = node:range()
        logger.debug_node(capture, node)

        if capture == 'code' then
            vim.api.nvim_buf_set_extmark(0, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                hl_group = highlights.code,
            })
        else
            -- Should only get here if user provides custom capture, currently unhandled
            logger.error('Unhandled inline capture: ' .. capture)
        end
    end
end

return M
