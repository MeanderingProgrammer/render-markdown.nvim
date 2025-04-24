local Iter = require('render-markdown.lib.iter')
local Str = require('render-markdown.lib.str')

---@class render.md.Node
---@field private buf integer
---@field private node TSNode
---@field type string
---@field text string
---@field start_row integer
---@field start_col integer
---@field end_row integer
---@field end_col integer
local Node = {}
Node.__index = Node

---@param buf integer
---@param node TSNode
---@return render.md.Node
function Node.new(buf, node)
    local self = setmetatable({}, Node)
    self.buf = buf
    self.node = node
    self.type = node:type()
    self.text = vim.treesitter.get_node_text(node, buf)
    local start_row, start_col, end_row, end_col = node:range()
    self.start_row = start_row
    self.start_col = start_col
    self.end_row = end_row
    self.end_col = end_col
    return self
end

---@param a render.md.Node
---@param b render.md.Node
---@return boolean
function Node.__lt(a, b)
    if a.start_row ~= b.start_row then
        return a.start_row < b.start_row
    else
        return a.start_col < b.start_col
    end
end

---@private
---@param node TSNode
---@return render.md.Node
function Node:create(node)
    return Node.new(self.buf, node)
end

---@return TSNode
function Node:get()
    return self.node
end

---@return integer[]
function Node:sections()
    local result = {} ---@type integer[]
    local levels = 0
    local section = self:parent('section')
    while section ~= nil do
        local level = section:level(false)
        result[level] = section:sibling_count('section', level)
        levels = math.max(levels, level)
        section = section:parent('section')
    end
    -- fill in any heading level gaps with 0
    for i = 1, levels do
        result[i] = result[i] or 0
    end
    return result
end

---@param parent boolean
---@return integer
function Node:level(parent)
    local section = not parent and self or self:parent('section')
    if section == nil then
        return 0
    end
    assert(section.type == 'section', 'must be a section')
    local heading = section:child('atx_heading')
    local node = heading ~= nil and heading.node:child(0) or nil
    -- counts the number of hashtags in the heading marker
    return node ~= nil and #vim.treesitter.get_node_text(node, self.buf) or 0
end

---@param target string
---@return integer, render.md.Node?
function Node:level_in_section(target)
    local level = 0
    local root = nil ---@type TSNode?
    local node = self.node ---@type TSNode?
    while node ~= nil and node:type() ~= 'section' do
        if node:type() == target then
            level = level + 1
            root = node
        end
        node = node:parent()
    end
    return level, root ~= nil and self:create(root) or nil
end

---@param target string
---@return render.md.Node?
function Node:parent(target)
    local node = self.node:parent()
    while node ~= nil do
        if node:type() == target then
            return self:create(node)
        end
        node = node:parent()
    end
    return nil
end

---@param target string
---@return render.md.Node?
function Node:sibling(target)
    local node = self.node ---@type TSNode?
    while node ~= nil do
        if node:type() == target then
            return self:create(node)
        end
        node = node:next_sibling()
    end
    return nil
end

---@param target string
---@param level? integer
---@return integer
function Node:sibling_count(target, level)
    local count = 0
    local node = self.node ---@type TSNode?
    while
        node ~= nil
        and node:type() == target
        and (level == nil or self:create(node):level(false) == level)
    do
        count = count + 1
        node = node:prev_sibling()
    end
    return count
end

---@param index integer
---@return render.md.Node?
function Node:child_at(index)
    local node = self.node:named_child(index)
    return node ~= nil and self:create(node) or nil
end

---@param target string
---@param row? integer
---@return render.md.Node?
function Node:child(target, row)
    for node in self.node:iter_children() do
        if node:type() == target then
            if row == nil or node:range() == row then
                return self:create(node)
            end
        end
    end
    return nil
end

---@param callback fun(node: render.md.Node)
function Node:for_each_child(callback)
    for node in self.node:iter_children() do
        callback(self:create(node))
    end
end

---@param target string
---@return render.md.Node?
function Node:descendant(target)
    for node in self.node:iter_children() do
        local child = self:create(node)
        if child.type == target then
            return child
        end
        local nested = child:descendant(target)
        if nested ~= nil then
            return nested
        end
    end
    return nil
end

---@return string?
function Node:after()
    local row, col = self.end_row, self.end_col
    return vim.api.nvim_buf_get_text(self.buf, row, col, row, col + 1, {})[1]
end

---@param position 'above'|'first'|'below'|'last'
---@param by integer
---@return string?
function Node:line(position, by)
    local row = nil
    local single = self.start_row == self.end_row
    if position == 'above' then
        row = self.start_row - by
    elseif position == 'first' then
        row = self.start_row + by
    elseif position == 'below' then
        row = self.end_row - (single and 0 or 1) + by
    elseif position == 'last' then
        row = self.end_row - (single and 0 or 1) - by
    end
    if row == nil then
        return nil
    end
    return vim.api.nvim_buf_get_lines(self.buf, row, row + 1, false)[1]
end

---@return integer[]
function Node:widths()
    local lines = vim.api.nvim_buf_get_lines(
        self.buf,
        self.start_row,
        self.end_row,
        false
    )
    return Iter.list.map(lines, Str.width)
end

---@param pattern string
---@return Range4[]
function Node:find(pattern)
    local result = {} ---@type Range4[]
    local index = 1 ---@type integer?
    while index ~= nil do
        local start_index, end_index = self.text:find(pattern, index)
        if start_index == nil or end_index == nil then
            index = nil
        else
            index = end_index + 1
            -- start : 1-based inclusive -> 0-based inclusive = -1 offset
            -- end   : 1-based inclusive -> 0-based exclusive =  0 offset
            local start_row, start_col = self:position(start_index, -1)
            local end_row, end_col = self:position(end_index, 0)
            result[#result + 1] = { start_row, start_col, end_row, end_col }
        end
    end
    return result
end

---@private
---@param index integer
---@param offset integer
---@return integer, integer
function Node:position(index, offset)
    local lines = Str.split(self.text:sub(1, index), '\n', false)
    -- start row includes first line
    local row = self.start_row + #lines - 1
    local col = #lines[#lines] + offset
    if row == self.start_row then
        col = col + self.start_col
    end
    return row, col
end

return Node
