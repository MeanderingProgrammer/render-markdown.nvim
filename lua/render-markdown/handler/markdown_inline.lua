local component = require('render-markdown.component')
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
    local value = vim.treesitter.get_node_text(node, buf)
    local start_row, start_col, end_row, end_col = node:range()
    logger.debug_node(capture, node, buf)

    if capture == 'code' then
        local code = state.config.code
        if not code.enabled then
            return
        end
        if not vim.tbl_contains({ 'normal', 'full' }, code.style) then
            return
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            hl_group = code.highlight,
        })
    elseif capture == 'callout' then
        local callout = component.callout(value, 'exact')
        if callout ~= nil then
            if not state.config.quote.enabled then
                return
            end
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { { callout.text, callout.highlight } },
                virt_text_pos = 'overlay',
            })
        else
            if not state.config.checkbox.enabled then
                return
            end
            -- Requires inline extmarks
            if not util.has_10 then
                return
            end
            local checkbox = component.checkbox(value, 'exact')
            if checkbox == nil then
                return
            end
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { { str.pad_to(value, checkbox.text), checkbox.highlight } },
                virt_text_pos = 'inline',
                conceal = '',
            })
        end
    elseif vim.tbl_contains({ 'link', 'image' }, capture) then
        local link = state.config.link
        if not link.enabled then
            return
        end
        -- Requires inline extmarks
        if not util.has_10 then
            return
        end
        local icon = link.hyperlink
        if capture == 'image' then
            icon = link.image
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            virt_text = { { icon, link.highlight } },
            virt_text_pos = 'inline',
        })
    else
        -- Should only get here if user provides custom capture, currently unhandled
        logger.error('Unhandled inline capture: ' .. capture)
    end
end

return M
