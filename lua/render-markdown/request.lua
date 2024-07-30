local util = require('render-markdown.util')

---@class render.md.RequestCache
local cache = {
    ---@type table<integer, table<integer, { [1]: integer, [2]: integer }[]>>
    conceal = {},
    ---@type table<integer, table<integer, { [1]: integer, [2]: integer, [3]: string }[]>>
    inline_links = {},
}

---@class render.md.Request
local M = {}

---@param buf integer
function M.reset_buf(buf)
    cache.conceal[buf] = {}
    cache.inline_links[buf] = {}
end

---@param buf integer
---@param parser vim.treesitter.LanguageTree
function M.compute_conceal(buf, parser)
    if util.get_win(util.buf_to_win(buf), 'conceallevel') == 0 then
        cache.conceal[buf] = {}
        return
    end

    local nodes = {}
    parser:for_each_tree(function(tree, language_tree)
        local language = language_tree:lang()
        if vim.tbl_contains({ 'markdown', 'markdown_inline' }, language) then
            local query = vim.treesitter.query.get(language, 'highlights')
            if query ~= nil then
                for _, node, metadata in query:iter_captures(tree:root(), buf, 0, -1) do
                    if metadata.conceal ~= nil then
                        local row, start_col, _, end_col = node:range()
                        if nodes[row] == nil then
                            nodes[row] = {}
                        end
                        table.insert(nodes[row], { start_col, end_col })
                    end
                end
            end
        end
    end)
    cache.conceal[buf] = nodes
end

---@param buf integer
---@param row integer
---@return { [1]: integer, [2]: integer }[]
function M.concealed(buf, row)
    return cache.conceal[buf][row] or {}
end

---@param buf integer
---@param info render.md.NodeInfo
---@param icon string
function M.add_inline_link(buf, info, icon)
    local inline_links = cache.inline_links[buf]
    local row = info.start_row
    if inline_links[row] == nil then
        inline_links[row] = {}
    end
    table.insert(inline_links[row], { info.start_col, info.end_col, icon })
end

---@param buf integer
---@param row integer
---@return { [1]: integer, [2]: integer, [3]: string }[]
function M.inline_links(buf, row)
    return cache.inline_links[buf][row] or {}
end

return M
