---@class render.md.Context
---@field private buf integer
---@field private win integer
---@field private top integer
---@field private bottom integer
---@field private conceal? table<integer, [integer, integer][]>
---@field private links table<integer, [integer, integer, string][]>
local Context = {}
Context.__index = Context

---@param buf integer
---@param win integer
---@param offset integer
---@return render.md.Context
function Context.new(buf, win, offset)
    local self = setmetatable({}, Context)
    self.buf = buf
    self.win = win
    local top = vim.api.nvim_win_call(win, vim.fn.winsaveview).topline - 1
    local height = vim.api.nvim_win_get_height(win)
    local lines = vim.api.nvim_buf_line_count(buf)
    self.top = math.max(top - offset, 0)
    self.bottom = math.min(top + height + offset, lines)
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

---@param other render.md.Context
---@return boolean
function Context:contains_range(other)
    return self.top <= other.top and self.bottom >= other.bottom
end

---@return Range2
function Context:range()
    return { self.top, self.bottom }
end

---@param node TSNode
---@return boolean
function Context:contains_node(node)
    local top, _, bottom, _ = node:range()
    return top <= self.bottom and bottom >= self.top
end

---@param root TSNode
---@param query vim.treesitter.Query
---@param cb fun(capture: string, node: TSNode, metadata: vim.treesitter.query.TSMetadata)
function Context:query(root, query, cb)
    for id, node, metadata in query:iter_captures(root, self.buf, self.top, self.bottom) do
        local capture = query.captures[id]
        cb(capture, node, metadata)
    end
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
    local conceallevel = vim.api.nvim_get_option_value('conceallevel', { scope = 'local', win = self.win })
    if conceallevel == 0 then
        return {}
    end
    local ranges = {}
    local parser = vim.treesitter.get_parser(self.buf)
    parser:parse(self:range())
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
    if not self:contains_node(root) then
        return {}
    end
    if not vim.tbl_contains({ 'markdown', 'markdown_inline' }, language) then
        return {}
    end
    local query = vim.treesitter.query.get(language, 'highlights')
    if query == nil then
        return {}
    end
    local nodes = {}
    self:query(root, query, function(_, node, metadata)
        if metadata.conceal ~= nil then
            table.insert(nodes, node)
        end
    end)
    return nodes
end

---@type table<integer, render.md.Context>
local cache = {}

---@class render.md.ContextManager
local M = {}

---@param buf integer
---@param win integer
function M.reset(buf, win)
    cache[buf] = Context.new(buf, win, 10)
end

---@param buf integer
---@param win integer
---@return boolean
function M.contains_range(buf, win)
    local context = cache[buf]
    if context == nil then
        return false
    end
    return context:contains_range(Context.new(buf, win, 0))
end

---@param buf integer
---@return render.md.Context
function M.get(buf)
    return cache[buf]
end

return M
