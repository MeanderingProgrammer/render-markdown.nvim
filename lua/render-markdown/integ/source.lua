local manager = require('render-markdown.manager')
local state = require('render-markdown.state')
local util = require('render-markdown.core.util')

local list_markers = {
    'list_marker_minus',
    'list_marker_star',
    'list_marker_plus',
}

---@class render.md.Source
local M = {}

---@private
---@param row integer
---@param node TSNode
---@return string
function M.list_prefix(row, node)
    local marker = node:named_child(0)
    if not marker then
        return ''
    end

    local marker_row = marker:range()
    if marker_row == row then
        return '' -- Don't run if on the same line, entry should already have a list marker.
    end

    local start_row = select(1, marker:range())
    -- Retrieve the line from the buffer
    local marker_line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]

    if not marker_line or #marker_line == 0 then
        return '' -- Return empty if the line is empty or doesn't exist
    end

    -- Define valid list markers
    local valid_markers = { ['-'] = true, ['+'] = true, ['*'] = true }
    local first_char = marker_line:match('%S')

    -- Return corresponding marker if valid, otherwise default to empty string
    return valid_markers[first_char] and first_char .. ' ' or ''
end

---@return boolean
function M.enabled()
    return manager.is_attached(util.current('buf'))
end

---@return string[]
function M.trigger_characters()
    return { '-', '*', '+', '>', ' ', '[' }
end

---@param buf integer
---@param row integer
---@param col integer
---@return lsp.CompletionItem[]?
function M.items(buf, row, col)
    local node = vim.treesitter.get_node({ bufnr = buf, pos = { row, col } })
    if node == nil then
        return nil
    end

    local items = {}
    local config = state.get(buf)
    if vim.tbl_contains({ 'block_quote', 'block_quote_marker' }, node:type()) then
        for _, component in pairs(config.callout) do
            table.insert(items, M.item(component.raw, component.rendered, nil))
        end
    elseif node:type() == 'list_item' or vim.tbl_contains(list_markers, node:type()) then
        local last_marker = M.list_prefix(row, node)
        print(last_marker)
        local checkbox = config.checkbox
        table.insert(items, M.item(last_marker .. '[ ] ', checkbox.unchecked.icon, 'unchecked'))
        table.insert(items, M.item(last_marker .. '[x] ', checkbox.checked.icon, 'checked'))
        for name, component in pairs(checkbox.custom) do
            table.insert(items, M.item(component.raw, component.rendered, name))
        end
    end
    return items
end

---@private
---@param raw string
---@param rendered string
---@param name? string
---@return lsp.CompletionItem
function M.item(raw, rendered, name)
    ---@type lsp.CompletionItem
    return {
        label = raw,
        labelDetails = {
            detail = rendered,
            description = name,
        },
        kind = 12,
    }
end

return M
