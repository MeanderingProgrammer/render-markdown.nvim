---@class render.md.Context
---@field private buf integer
---@field private win integer
---@field private conceallevel integer
---@field private conceal? table<integer, [integer, integer][]>
---@field private links table<integer, [integer, integer, string][]>
local Context = {}
Context.__index = Context

---@param buf integer
---@param win integer
function Context.new(buf, win)
    local self = setmetatable({}, Context)
    self.buf = buf
    self.win = win
    self.conceallevel = vim.api.nvim_get_option_value('conceallevel', { scope = 'local', win = win })
    self.conceal = nil
    self.links = {}
    return self
end

---@param info render.md.NodeInfo
---@param icon string
function Context:add_link(info, icon)
    local row = info.start_row
    if self.links[row] == nil then
        self.links[row] = {}
    end
    table.insert(self.links[row], { info.start_col, info.end_col, icon })
end

---@param row integer
---@return [integer, integer, string][]
function Context:get_links(row)
    return self.links[row] or {}
end

---@return integer
function Context:get_width()
    return vim.api.nvim_win_get_width(self.win)
end

---@param row integer
---@return [integer, integer][]
function Context:get_conceal(row)
    if self.conceal == nil then
        self.conceal = self:compute_conceal()
    end
    return self.conceal[row] or {}
end

---Cached row level implementation of vim.treesitter.get_captures_at_pos
---@private
---@return table<integer, [integer, integer][]>
function Context:compute_conceal()
    if self.conceallevel == 0 then
        return {}
    end
    local ranges = {}
    local parser = vim.treesitter.get_parser(self.buf)
    parser:for_each_tree(function(tree, language_tree)
        local nodes = self:compute_conceal_nodes(language_tree:lang(), tree:root())
        for _, node in ipairs(nodes) do
            local row, start_col, _, end_col = node:range()
            if ranges[row] == nil then
                ranges[row] = {}
            end
            table.insert(ranges[row], { start_col, end_col })
        end
    end)
    return ranges
end

---@private
---@param language string
---@param root TSNode
---@return TSNode[]
function Context:compute_conceal_nodes(language, root)
    if not vim.tbl_contains({ 'markdown', 'markdown_inline' }, language) then
        return {}
    end
    local query = vim.treesitter.query.get(language, 'highlights')
    if query == nil then
        return {}
    end
    local nodes = {}
    for _, node, metadata in query:iter_captures(root, self.buf) do
        if metadata.conceal ~= nil then
            table.insert(nodes, node)
        end
    end
    return nodes
end

---@type table<integer, render.md.Context>
local cache = {}

---@class render.md.ContextManager
local M = {}

---@param buf integer
---@param win integer
function M.reset(buf, win)
    cache[buf] = Context.new(buf, win)
end

---@param buf integer
---@return render.md.Context
function M.get(buf)
    return cache[buf]
end

return M
