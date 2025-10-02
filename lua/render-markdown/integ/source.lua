local Node = require('render-markdown.lib.node')
local env = require('render-markdown.lib.env')
local manager = require('render-markdown.core.manager')
local state = require('render-markdown.state')

local markers = {
    list_marker_minus = '-',
    list_marker_star = '*',
    list_marker_plus = '+',
    block_quote_marker = '>',
}

local children = vim.list_extend(vim.tbl_keys(markers), {
    'block_continuation',
    'inline',
    'task_list_marker_checked',
    'task_list_marker_unchecked',
})

local siblings = { 'paragraph' }

---@class render.md.Source
local M = {}

---@return boolean
function M.enabled()
    return manager.attached(env.buf.current())
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
    buf = buf == 0 and env.buf.current() or buf
    local node = M.node(buf, row, col, 'markdown')
    if not node or node.start_row ~= row then
        return nil
    end
    local marker = node:child_at(0)
    if not marker then
        return nil
    end
    local _, line = node:line('first', 0)
    if not line then
        return nil
    end
    local before, after = math.min(marker.end_col, col), col + 1
    local text = line:sub(before + 1, after - 1)
    if M.ignore(text) then
        return nil
    end

    local items = {} ---@type lsp.CompletionItem[]
    local config = state.get(buf)
    local filter = state.completions.filter
    local prefix = line:sub(before, before) == ' ' and '' or ' '
    if node.type == 'block_quote' then
        local suffix = ''
        for _, value in pairs(config.callout) do
            if filter.callout(value) then
                M.append(items, prefix, suffix, value.raw, value.rendered)
            end
        end
    elseif node.type == 'list_item' then
        local suffix = line:sub(after, after) == ' ' and '' or ' '
        local unchecked = config.checkbox.unchecked
        M.append(items, prefix, suffix, '[ ]', unchecked.icon, 'unchecked')
        local checked = config.checkbox.checked
        M.append(items, prefix, suffix, '[x]', checked.icon, 'checked')
        for name, value in pairs(config.checkbox.custom) do
            if filter.checkbox(value) then
                M.append(items, prefix, suffix, value.raw, value.rendered, name)
            end
        end
    end
    return items
end

---@private
---@param buf integer
---@param row integer
---@param col integer
---@param lang string
---@return render.md.Node?
function M.node(buf, row, col, lang)
    -- parse current row to get up to date node
    local ok, parser = pcall(vim.treesitter.get_parser, buf, lang)
    if not ok or not parser then
        return nil
    end
    parser:parse({ row, row })
    local node = vim.treesitter.get_node({
        bufnr = buf,
        pos = { row, col },
        lang = lang,
    })
    while node do
        if vim.tbl_contains(children, node:type()) then
            node = node:parent()
        elseif vim.tbl_contains(siblings, node:type()) then
            node = node:prev_sibling()
        else
            return Node.new(buf, node)
        end
    end
    return nil
end

---@private
---@param text string
---@return boolean
function M.ignore(text)
    local patterns = {} ---@type string[]
    -- first character is not '['
    patterns[#patterns + 1] = '^[^%[]'
    -- after '[' there is another '[' or a space
    patterns[#patterns + 1] = '^%[.*[%[%s]'
    -- there is already text enclosed by '[' ']'
    patterns[#patterns + 1] = '^%[.*%]'
    for _, pattern in ipairs(patterns) do
        if text:find(pattern) then
            return true
        end
    end
    return false
end

---@private
---@param items lsp.CompletionItem[]
---@param prefix string
---@param suffix string
---@param label string
---@param detail string
---@param description? string
function M.append(items, prefix, suffix, label, detail, description)
    items[#items + 1] = {
        kind = 12,
        label = label,
        labelDetails = {
            detail = ' ' .. detail,
            description = description,
        },
        insertText = prefix .. label .. suffix,
    }
end

return M
