local Node = require('render-markdown.lib.node')
local Range = require('render-markdown.core.range')
local Str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')
local util = require('render-markdown.core.util')

---@class render.md.context.Conceal
---@field enabled boolean
---@field block integer
---@field char boolean
---@field rows? table<integer, [integer, integer, integer][]>

---@class render.md.Context
---@field private buf integer
---@field private win integer
---@field private ranges render.md.Range[]
---@field private callouts table<integer, render.md.CustomCallout>
---@field private checkboxes table<integer, render.md.CustomCheckbox>
---@field private links table<integer, [integer, integer, integer][]>
---@field private window_width? integer
---@field mode string
---@field conceal render.md.context.Conceal
---@field last_heading? integer
local Context = {}
Context.__index = Context

---@param buf integer
---@param win integer
---@param mode string
---@param offset integer
---@return render.md.Context
function Context.new(buf, win, mode, offset)
    local self = setmetatable({}, Context)
    self.buf = buf
    self.win = win

    local ranges = {}
    for _, window in ipairs(util.windows(buf)) do
        table.insert(ranges, Context.compute_range(self.buf, window, offset))
    end
    self.ranges = Range.coalesce(ranges)

    self.callouts = {}
    self.checkboxes = {}
    self.links = {}
    self.window_width = nil
    self.mode = mode

    local conceal_level = util.get('win', self.win, 'conceallevel')
    self.conceal = {
        enabled = conceal_level > 0,
        -- At conceal level 1 each block is replaced with one character
        block = conceal_level == 1 and 1 or 0,
        -- At conceal level 2 replacement character width is used
        char = conceal_level == 2,
        rows = nil,
    }

    self.last_heading = nil
    return self
end

---@private
---@param buf integer
---@param win integer
---@param offset integer
---@return render.md.Range
function Context.compute_range(buf, win, offset)
    local top = math.max(util.view(win).topline - 1 - offset, 0)

    local bottom = top
    local lines = vim.api.nvim_buf_line_count(buf)
    local size = vim.api.nvim_win_get_height(win) + (2 * offset)
    while bottom < lines and size > 0 do
        bottom = bottom + 1
        if util.row_visible(win, bottom) then
            size = size - 1
        end
    end

    return Range.new(top, bottom)
end

---@param node render.md.Node
---@return render.md.CustomCallout?
function Context:get_callout(node)
    return self.callouts[node.start_row]
end

---@param node render.md.Node
---@param callout render.md.CustomCallout
function Context:add_callout(node, callout)
    self.callouts[node.start_row] = callout
end

---@param node render.md.Node
---@return render.md.CustomCheckbox?
function Context:get_checkbox(node)
    return self.checkboxes[node.start_row]
end

---@param node render.md.Node
---@param checkbox render.md.CustomCheckbox
function Context:add_checkbox(node, checkbox)
    self.checkboxes[node.start_row] = checkbox
end

---@return integer
function Context:tab_size()
    return util.get('buf', self.buf, 'tabstop')
end

---@param node? render.md.Node
---@return integer
function Context:width(node)
    if node == nil then
        return 0
    end
    return Str.width(node.text) + self:get_offset(node) - self:concealed(node)
end

---@param node render.md.Node
---@param amount integer
function Context:add_offset(node, amount)
    if amount == 0 then
        return
    end
    local row = node.start_row
    if self.links[row] == nil then
        self.links[row] = {}
    end
    table.insert(self.links[row], { node.start_col, node.end_col, amount })
end

---@private
---@param node render.md.Node
---@return integer
function Context:get_offset(node)
    local result = 0
    for _, offset_range in ipairs(self.links[node.start_row] or {}) do
        if node.start_col < offset_range[2] and node.end_col > offset_range[1] then
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

---@private
---@return integer
function Context:get_width()
    if self.window_width == nil then
        self.window_width = vim.api.nvim_win_get_width(self.win) - util.textoff(self.win)
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
---@param callback fun(capture: string, node: render.md.Node)
function Context:query(root, query, callback)
    for _, range in ipairs(self.ranges) do
        for id, ts_node in query:iter_captures(root, self.buf, range.top, range.bottom) do
            local capture = query.captures[id]
            local node = Node.new(self.buf, ts_node)
            log.node(capture, node)
            callback(capture, node)
        end
    end
end

---@param node? render.md.Node
---@return boolean
function Context:hidden(node)
    return node == nil or Str.width(node.text) == self:concealed(node)
end

---@param node render.md.Node
---@return integer
function Context:concealed(node)
    local ranges = self:get_conceal(node.start_row)
    if #ranges == 0 then
        return 0
    end
    local result, col = 0, node.start_col
    for _, index in ipairs(vim.fn.str2list(node.text)) do
        local ch = vim.fn.nr2char(index)
        for _, range in ipairs(ranges) do
            -- Column level implementation of vim.treesitter.is_in_node_range
            if col >= range[1] and col + 1 <= range[2] then
                result = result + Str.width(ch)
                if col == range[1] then
                    result = result - self.conceal.block - range[3]
                end
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
    if self.conceal.rows == nil then
        self.conceal.rows = self:compute_conceal()
    end
    return self.conceal.rows[row] or {}
end

---Cached row level implementation of vim.treesitter.get_captures_at_pos
---@private
---@return table<integer, [integer, integer, integer][]>
function Context:compute_conceal()
    if not self.conceal.enabled then
        return {}
    end
    local ranges = {}
    local parser = vim.treesitter.get_parser(self.buf)
    self:parse(parser)
    parser:for_each_tree(function(tree, language_tree)
        local conceal_ranges = self:compute_conceal_ranges(language_tree:lang(), tree:root())
        for _, conceal_range in ipairs(conceal_ranges) do
            local row, start_col, end_col, char = unpack(conceal_range)
            if ranges[row] == nil then
                ranges[row] = {}
            end
            table.insert(ranges[row], { start_col, end_col, self.conceal.char and Str.width(char) or 0 })
        end
    end)
    return ranges
end

---@private
---@param language string
---@param root TSNode
---@return [integer, integer, integer, string][]
function Context:compute_conceal_ranges(language, root)
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
    local result = {}
    for _, range in ipairs(self.ranges) do
        for id, ts_node, metadata in query:iter_captures(root, self.buf, range.top, range.bottom) do
            if metadata.conceal ~= nil then
                local node_range = metadata.range
                if node_range == nil and metadata[id] ~= nil then
                    node_range = metadata[id].range
                end
                if node_range == nil then
                    ---@diagnostic disable-next-line: missing-fields
                    node_range = { ts_node:range() }
                end
                local row, start_col, _, end_col = unpack(node_range)
                table.insert(result, { row, start_col, end_col, metadata.conceal })
            end
        end
    end
    return result
end

---@type table<integer, render.md.Context>
local cache = {}

---@class render.md.ContextManager
local M = {}

---@param buf integer
---@param win integer
---@param mode string
function M.reset(buf, win, mode)
    cache[buf] = Context.new(buf, win, mode, 10)
end

---@param buf integer
---@param win integer
---@return boolean
function M.contains_range(buf, win)
    local context = cache[buf]
    return context ~= nil and context:contains_window(win)
end

---@param buf integer
---@return render.md.Context
function M.get(buf)
    return cache[buf]
end

return M
