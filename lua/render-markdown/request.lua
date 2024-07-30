local util = require('render-markdown.util')

---@class render.md.RequestCache
local cache = {
    ---@type table<integer, TSNode[]>
    conceal = {},
}

---@class render.md.Request
local M = {}

---@param buf integer
function M.reset_buf(buf)
    cache.conceal[buf] = {}
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
                        table.insert(nodes, node)
                    end
                end
            end
        end
    end)
    cache.conceal[buf] = nodes
end

---@param buf integer
---@param row integer
---@param col integer
---@return boolean
function M.concealed(buf, row, col)
    for _, node in ipairs(cache.conceal[buf]) do
        if vim.treesitter.is_in_node_range(node, row, col) then
            return true
        end
    end
    return false
end

return M
