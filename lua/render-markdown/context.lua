local util = require('render-markdown.util')

---@class render.md.ContextCache
local cache = {
    ---@type table<integer, table<integer, [integer, integer][]>>
    conceal = {},
    ---@type table<integer, table<integer, [integer, integer, string][]>>
    inline_links = {},
}

---@class render.md.Context
local M = {}

---@param buf integer
function M.reset_buf(buf)
    cache.conceal[buf] = {}
    cache.inline_links[buf] = {}
end

---@param buf integer
---@param parser vim.treesitter.LanguageTree
function M.compute_conceal(buf, parser)
    local ranges = {}
    if util.get_win(util.buf_to_win(buf), 'conceallevel') > 0 then
        parser:for_each_tree(function(tree, language_tree)
            local nodes = M.get_conceal_nodes(buf, language_tree:lang(), tree:root())
            for _, node in ipairs(nodes) do
                local row, start_col, _, end_col = node:range()
                if ranges[row] == nil then
                    ranges[row] = {}
                end
                table.insert(ranges[row], { start_col, end_col })
            end
        end)
    end
    cache.conceal[buf] = ranges
end

---@private
---@param buf integer
---@param language string
---@param root TSNode
---@return TSNode[]
function M.get_conceal_nodes(buf, language, root)
    if not vim.tbl_contains({ 'markdown', 'markdown_inline' }, language) then
        return {}
    end
    local query = vim.treesitter.query.get(language, 'highlights')
    if query == nil then
        return {}
    end
    local nodes = {}
    for _, node, metadata in query:iter_captures(root, buf) do
        if metadata.conceal ~= nil then
            table.insert(nodes, node)
        end
    end
    return nodes
end

---@param buf integer
---@param row integer
---@return [integer, integer][]
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
---@return [integer, integer, string][]
function M.inline_links(buf, row)
    return cache.inline_links[buf][row] or {}
end

return M
