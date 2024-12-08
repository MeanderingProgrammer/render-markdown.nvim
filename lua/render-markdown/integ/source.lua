local manager = require('render-markdown.manager')
local state = require('render-markdown.state')
local util = require('render-markdown.core.util')

---@class render.md.Source
local M = {}

---@return boolean
function M.enabled()
    return manager.is_attached(util.current('buf'))
end

---@return string[]
function M.trigger_characters()
    return { ' ', '[' }
end

---@param buf integer
---@param row integer
---@param col integer
---@return lsp.CompletionItem[]?
function M.items(buf, row, col)
    local node = vim.treesitter.get_node({
        bufnr = buf,
        pos = { row, col },
    })
    if node == nil then
        return nil
    end
    local node_type = node:type()
    local config = state.get(buf)
    local items = {}
    if vim.tbl_contains({ 'block_quote', 'block_quote_marker' }, node_type) then
        for _, component in pairs(config.callout) do
            table.insert(items, M.item(component.raw, component.rendered, nil))
        end
    elseif vim.tbl_contains({ 'list_item', 'list_marker_minus' }, node_type) then
        local checkbox = config.checkbox
        table.insert(items, M.item('[ ]', checkbox.unchecked.icon, 'unchecked'))
        table.insert(items, M.item('[x]', checkbox.checked.icon, 'checked'))
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
