local Str = require('render-markdown.lib.str')

---@class render.md.Conceal
---@field private buf integer
---@field private level integer
---@field private computed boolean
---@field private rows table<integer, [integer, integer, integer][]>
local Conceal = {}
Conceal.__index = Conceal

---@param buf integer
---@param level integer
---@return render.md.Conceal
function Conceal.new(buf, level)
    local self = setmetatable({}, Conceal)
    self.buf = buf
    self.level = level
    self.computed = false
    self.rows = {}
    return self
end

---@return boolean
function Conceal:enabled()
    return self.level > 0
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param amount integer
---@param character? string
function Conceal:add(row, start_col, end_col, amount, character)
    if not self:enabled() or amount == 0 then
        return
    end
    if self.rows[row] == nil then
        self.rows[row] = {}
    end
    -- If the range is already concealed by another don't add it
    for _, range in ipairs(self.rows[row]) do
        if range[1] <= start_col and range[2] >= end_col then
            return
        end
    end
    table.insert(self.rows[row], { start_col, end_col, self:adjust(amount, character) })
end

---@param amount integer
---@param character? string
---@return integer
function Conceal:adjust(amount, character)
    if self.level == 1 then
        -- Level 1: each block is replaced with one character
        amount = amount - 1
    elseif self.level == 2 then
        -- Level 2: replacement character width is used
        amount = amount - Str.width(character)
    end
    return amount
end

---@param context render.md.Context
---@param node render.md.Node
---@return integer
function Conceal:get(context, node)
    if not self.computed then
        self.computed = true
        self:compute(context)
    end

    local result = 0
    local ranges = self.rows[node.start_row] or {}
    for _, range in ipairs(ranges) do
        if node.start_col < range[2] and node.end_col > range[1] then
            result = result + range[3]
        end
    end
    return result
end

---Cached row level implementation of vim.treesitter.get_captures_at_pos
---@private
---@param context render.md.Context
function Conceal:compute(context)
    if not self:enabled() then
        return
    end
    if vim.treesitter.highlighter.active[self.buf] == nil then
        return
    end
    local parser = vim.treesitter.get_parser(self.buf)
    context:parse(parser)
    parser:for_each_tree(function(tree, language_tree)
        self:compute_tree(context, language_tree:lang(), tree:root())
    end)
end

---@private
---@param context render.md.Context
---@param language string
---@param root TSNode
function Conceal:compute_tree(context, language, root)
    if not context:overlaps_node(root) then
        return
    end
    if not vim.tbl_contains({ 'markdown', 'markdown_inline' }, language) then
        return
    end
    local query = vim.treesitter.query.get(language, 'highlights')
    if query == nil then
        return
    end
    context:for_each(function(range)
        for id, node, metadata in query:iter_captures(root, self.buf, range.top, range.bottom) do
            if metadata.conceal ~= nil then
                local node_range = metadata.range
                if node_range == nil and metadata[id] ~= nil then
                    node_range = metadata[id].range
                end
                if node_range == nil then
                    ---@diagnostic disable-next-line: missing-fields
                    node_range = { node:range() }
                end
                local row, start_col, _, end_col = unpack(node_range)
                local amount = Str.width(vim.treesitter.get_node_text(node, self.buf))
                self:add(row, start_col, end_col, amount, metadata.conceal)
            end
        end
    end)
end

return Conceal
