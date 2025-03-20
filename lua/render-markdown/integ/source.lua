local Str = require('render-markdown.lib.str')
local manager = require('render-markdown.manager')
local state = require('render-markdown.state')
local util = require('render-markdown.core.util')

local markers = {
    list_marker_minus = '-',
    list_marker_star = '*',
    list_marker_plus = '+',
    block_quote_marker = '>',
}

---@class render.md.Source
local M = {}

---@return boolean
function M.enabled()
    return manager.is_attached(util.current('buf'))
end

---@return string[]
function M.trigger_characters()
    return vim.list_extend(vim.tbl_values(markers), { ' ', '[', '!', ']' })
end

---@param buf integer 0 for current buffer
---@param row integer 0-indexed
---@param col integer 0-indexed
---@return lsp.CompletionItem[]?
function M.items(buf, row, col)
    buf = buf == 0 and util.current('buf') or buf
    local node = M.node(buf, row, col)
    if node == nil or node:range() ~= row then
        return nil
    end

    local marker_node = node:named_child(0)
    if marker_node == nil then
        return nil
    end

    local marker = vim.treesitter.get_node_text(marker_node, buf)
    local text = vim.treesitter.get_node_text(node, buf)
    if M.ignore(marker, text:gsub('\n$', '')) then
        return nil
    end

    local result = {}
    local config = state.get(buf)
    local prefix = Str.spaces('end', marker) == 0 and ' ' or ''
    if node:type() == 'block_quote' then
        for _, component in pairs(config.callout) do
            table.insert(result, M.item(prefix, component.raw, component.rendered, nil))
        end
    elseif node:type() == 'list_item' then
        local checkbox = config.checkbox
        table.insert(result, M.item(prefix, '[ ] ', checkbox.unchecked.icon, 'unchecked'))
        table.insert(result, M.item(prefix, '[x] ', checkbox.checked.icon, 'checked'))
        for name, component in pairs(checkbox.custom) do
            table.insert(result, M.item(prefix, component.raw .. ' ', component.rendered, name))
        end
    end
    return result
end

---@private
---@param buf integer
---@param row integer
---@param col integer
---@return TSNode?
function M.node(buf, row, col)
    -- Parse current row to get up to date node
    local has_parser, parser = pcall(vim.treesitter.get_parser, buf)
    if not has_parser or parser == nil then
        return nil
    end
    parser:parse({ row, row })

    local node = vim.treesitter.get_node({
        bufnr = buf,
        lang = 'markdown',
        pos = { row, col },
    })
    if node ~= nil and node:type() == 'paragraph' then
        node = node:prev_sibling()
    end
    local children = vim.list_extend(vim.tbl_keys(markers), { 'block_continuation' })
    if node ~= nil and vim.tbl_contains(children, node:type()) then
        node = node:parent()
    end
    return node
end

---@private
---@param marker string
---@param text string
---@return boolean
function M.ignore(marker, text)
    local prefix = vim.pesc(vim.trim(marker)) .. '%s+'
    local patterns = {
        -- The first non-space after the marker is not '['
        prefix .. '[^%[]',
        -- After '[' there is another '[' or a space
        prefix .. '%[.*[%[%s]',
        -- There is already text enclosed by '[' ']'
        prefix .. '%[.*%]',
    }
    for _, pattern in ipairs(patterns) do
        if text:find(pattern) ~= nil then
            return true
        end
    end
    return false
end

---@private
---@param prefix string
---@param label string
---@param detail string
---@param description? string
---@return lsp.CompletionItem
function M.item(prefix, label, detail, description)
    ---@type lsp.CompletionItem
    return {
        kind = 12,
        label = prefix .. label,
        labelDetails = {
            detail = detail,
            description = description,
        },
    }
end

return M
