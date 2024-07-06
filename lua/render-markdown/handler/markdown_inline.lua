local callout = require('render-markdown.callout')
local custom_checkbox = require('render-markdown.custom_checkbox')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local str = require('render-markdown.str')
local util = require('render-markdown.util')

local M = {}

---@param namespace integer
---@param root TSNode
---@param buf integer
M.render = function(namespace, root, buf)
    local query = state.inline_query
    for id, node in query:iter_captures(root, buf) do
        M.render_node(namespace, buf, query.captures[id], node)
    end
end

---@param namespace integer
---@param buf integer
---@param capture string
---@param node TSNode
M.render_node = function(namespace, buf, capture, node)
    local highlights = state.config.highlights
    local value = vim.treesitter.get_node_text(node, buf)
    local start_row, start_col, end_row, end_col = node:range()
    logger.debug_node(capture, node, buf)

    if capture == 'code' then
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            hl_group = highlights.code,
        })
    elseif capture == 'callout' then
        local key = callout.get_key_exact(value)
        if key ~= nil then
            local callout_text = { state.config.callout[key], highlights.callout[key] }
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { callout_text },
                virt_text_pos = 'overlay',
            })
        else
            -- Requires inline extmarks
            if not util.has_10 then
                return
            end

            local checkbox = custom_checkbox.get_exact(value)
            if checkbox == nil then
                return
            end

            local checkbox_text = { str.pad_to(value, checkbox.icon), checkbox.highlight }
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { checkbox_text },
                virt_text_pos = 'inline',
                conceal = '',
            })
        end
    else
        -- Should only get here if user provides custom capture, currently unhandled
        logger.error('Unhandled inline capture: ' .. capture)
    end
end

return M
