local NodeInfo = require('render-markdown.core.node_info')
local Range = require('render-markdown.core.range')
local log = require('render-markdown.core.log')
local str = require('render-markdown.core.str')
local util = require('render-markdown.core.util')

---@class render.md.Context
---@field private buf integer
---@field private win integer
---@field private ranges render.md.Range[]
---@field private components table<integer, render.md.CustomComponent>
---@field private conceal? table<integer, [integer, integer][]>
---@field private links table<integer, [integer, integer, integer][]>
---@field private window_width? integer
---@field last_heading integer
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

    local ranges = { Context.compute_range(self.buf, self.win, offset) }
    for _, window_id in ipairs(vim.fn.win_findbuf(buf)) do
        if window_id ~= self.win then
            table.insert(ranges, Context.compute_range(self.buf, window_id, offset))
        end
    end
    self.ranges = Range.coalesce(ranges)

    self.components = {}
    self.conceal = nil
    self.links = {}
    self.window_width = nil
    self.last_heading = -1
    return self
end

---@private
---@param buf integer
---@param win integer
---@param offset integer
---@return render.md.Range
function Context.compute_range(buf, win, offset)
    local top = util.view(win).topline - 1
    top = math.max(top - offset, 0)

    local bottom = top
    local lines = vim.api.nvim_buf_line_count(buf)
    local size = vim.api.nvim_win_get_height(win) + offset
    while bottom < lines and size > 0 do
        bottom = bottom + 1
        if util.visible(win, bottom) then
            size = size - 1
        end
    end

    return Range.new(top, bottom)
end

---@param info render.md.NodeInfo
---@return render.md.CustomComponent?
function Context:get_component(info)
    return self.components[info.start_row]
end

---@param info render.md.NodeInfo
---@param component render.md.CustomComponent
function Context:add_component(info, component)
    self.components[info.start_row] = component
end

---@param info? render.md.NodeInfo
---@return integer
function Context:width(info)
    if info == nil then
        return 0
    end
    return str.width(info.text) + self:get_offset(info) - self:concealed(info)
end

---@param info render.md.NodeInfo
---@param amount integer
function Context:add_offset(info, amount)
    if amount == 0 then
        return
    end
    local row = info.start_row
    if self.links[row] == nil then
        self.links[row] = {}
    end
    table.insert(self.links[row], { info.start_col, info.end_col, amount })
end

---@private
---@param info render.md.NodeInfo
---@return integer
function Context:get_offset(info)
    local result = 0
    for _, offset_range in ipairs(self.links[info.start_row] or {}) do
        if info.start_col < offset_range[2] and info.end_col > offset_range[1] then
            result = result + offset_range[3]
        end
    end
    return result
end

---@param offset number
---@param width integer
---@return integer
function Context:resolve_offset(offset, width)
    if offset <= 0 then
        return 0
    elseif offset < 1 then
        return math.floor(((self:get_width() - width) * offset) + 0.5)
    else
        return offset
    end
end

---@return integer
function Context:get_width()
    if self.window_width == nil then
        self.window_width = vim.api.nvim_win_get_width(self.win)
        local window_info = vim.fn.getwininfo(self.win)
        if #window_info == 1 then
            self.window_width = self.window_width - window_info[1].textoff
        end
    end
    return self.window_width
end

---@param win integer
---@return boolean
function Context:contains_window(win)
    local window_range = Context.compute_range(self.buf, win, 0)
    for _, range in ipairs(self.ranges) do
        if range:contains(window_range.top, window_range.bottom) then
            return true
        end
    end
    return false
end

---@param node TSNode
---@return boolean
function Context:overlaps_node(node)
    local top, _, bottom, _ = node:range()
    for _, range in ipairs(self.ranges) do
        if range:overlaps(top, bottom) then
            return true
        end
    end
    return false
end

---@param parser vim.treesitter.LanguageTree
function Context:parse(parser)
    for _, range in ipairs(self.ranges) do
        parser:parse({ range.top, range.bottom })
    end
end

---@param root TSNode
---@param query vim.treesitter.Query
---@param callback fun(capture: string, node: render.md.NodeInfo)
function Context:query(root, query, callback)
    for _, range in ipairs(self.ranges) do
        for id, node in query:iter_captures(root, self.buf, range.top, range.bottom) do
            local capture = query.captures[id]
            local info = NodeInfo.new(self.buf, node)
            log.node_info(capture, info)
            callback(capture, info)
        end
    end
end

---@param info? render.md.NodeInfo
---@return boolean
function Context:hidden(info)
    return info == nil or str.width(info.text) == self:concealed(info)
end

---@param info render.md.NodeInfo
---@return integer
function Context:concealed(info)
    local ranges = self:get_conceal(info.start_row)
    if #ranges == 0 then
        return 0
    end
    local result, col = 0, info.start_col
    for _, index in ipairs(vim.fn.str2list(info.text)) do
        local ch = vim.fn.nr2char(index)
        for _, range in ipairs(ranges) do
            -- Essentially vim.treesitter.is_in_node_range but only care about column
            if col >= range[1] and col + 1 <= range[2] then
                result = result + str.width(ch)
            end
        end
        col = col + #ch
    end
    return result
end

---@private
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
    local conceallevel = util.get_win(self.win, 'conceallevel')
    if conceallevel == 0 then
        return {}
    end
    local ranges = {}
    local parser = vim.treesitter.get_parser(self.buf)
    self:parse(parser)
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
    if not self:overlaps_node(root) then
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
    for _, range in ipairs(self.ranges) do
        for _, node, metadata in query:iter_captures(root, self.buf, range.top, range.bottom) do
            if metadata.conceal ~= nil then
                table.insert(nodes, node)
            end
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
    return context:contains_window(win)
end

---@param buf integer
---@return render.md.Context
function M.get(buf)
    return cache[buf]
end

return M
