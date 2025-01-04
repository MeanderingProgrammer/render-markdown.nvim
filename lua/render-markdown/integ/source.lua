local manager = require('render-markdown.manager')
local state = require('render-markdown.state')
local util = require('render-markdown.core.util')

local list_markers = {
    list_marker_minus = '-',
    list_marker_star = '*',
    list_marker_plus = '+',
}

---@class render.md.Source
local M = {}

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

    local children = { 'block_quote_marker', 'block_continuation' }
    if vim.tbl_contains(children, node:type()) or list_markers[node:type()] ~= nil then
        node = node:parent()
        if node == nil then
            return nil
        end
    end

    local items = {}
    local config = state.get(buf)
    if node:type() == 'block_quote' then
        local quote_row = node:range()
        if quote_row == row then
            for _, component in pairs(config.callout) do
                table.insert(items, M.item(component.raw, component.rendered, nil))
            end
        end
    elseif node:type() == 'list_item' then
        local checkbox = config.checkbox
        local prefix = M.list_prefix(row, node)
        table.insert(items, M.item(prefix .. '[ ] ', checkbox.unchecked.icon, 'unchecked'))
        table.insert(items, M.item(prefix .. '[x] ', checkbox.checked.icon, 'checked'))
        for name, component in pairs(checkbox.custom) do
            table.insert(items, M.item(prefix .. component.raw .. ' ', component.rendered, name))
        end
    end
    return items
end

---@private
---@param row integer
---@param node TSNode
---@return string
function M.list_prefix(row, node)
    local marker_node = node:named_child(0)
    if marker_node == nil then
        return ''
    end
    local marker_row = marker_node:range()
    if marker_row == row then
        return ''
    end
    local marker = list_markers[marker_node:type()]
    return marker ~= nil and marker .. ' ' or ''
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
