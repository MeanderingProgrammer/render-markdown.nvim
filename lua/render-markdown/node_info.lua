---@param node TSNode
---@return boolean
local function in_section(node)
    -- reaching a section or document means we are outside section
    return not vim.tbl_contains({ 'section', 'document' }, node:type())
end

---@class render.md.NodeInfo
---@field private buf integer
---@field private node TSNode
---@field type string
---@field text string
---@field start_row integer
---@field start_col integer
---@field end_row integer
---@field end_col integer
local NodeInfo = {}
NodeInfo.__index = NodeInfo

---@param buf integer
---@param node TSNode
---@return render.md.NodeInfo
function NodeInfo.new(buf, node)
    local self = setmetatable({}, NodeInfo)
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

---@param infos render.md.NodeInfo[]
function NodeInfo.sort_inplace(infos)
    table.sort(infos, function(info1, info2)
        if info1.start_row ~= info2.start_row then
            return info1.start_row < info2.start_row
        else
            return info1.start_col < info2.start_col
        end
    end)
end

---@return boolean
function NodeInfo:has_error()
    return self.node:has_error()
end

---@return integer
function NodeInfo:level()
    local level = 0
    local parent = self.node:parent()
    while parent ~= nil and parent:type() ~= 'document' do
        if parent:type() == 'section' then
            level = level + 1
        end
        parent = parent:parent()
    end
    return level
end

---Walk through parent nodes, count the number of target nodes
---@param target string
---@return integer
function NodeInfo:level_in_section(target)
    local level = 0
    local parent = self.node:parent()
    while parent ~= nil and in_section(parent) do
        if parent:type() == target then
            level = level + 1
        end
        parent = parent:parent()
    end
    return level
end

---@param target string
---@return render.md.NodeInfo?
function NodeInfo:parent(target)
    local parent = self.node:parent()
    while parent ~= nil do
        if parent:type() == target then
            return NodeInfo.new(self.buf, parent)
        end
        parent = parent:parent()
    end
    return nil
end

---@param target string
---@return render.md.NodeInfo?
function NodeInfo:sibling(target)
    local sibling = self.node:next_sibling()
    while sibling ~= nil do
        if sibling:type() == target then
            return NodeInfo.new(self.buf, sibling)
        end
        sibling = sibling:next_sibling()
    end
    return nil
end

---@param target_type string
---@param target_row? integer
---@return render.md.NodeInfo?
function NodeInfo:child(target_type, target_row)
    for child in self.node:iter_children() do
        if child:type() == target_type then
            if target_row == nil or child:range() == target_row then
                return NodeInfo.new(self.buf, child)
            end
        end
    end
    return nil
end

---@param callback fun(node: render.md.NodeInfo)
function NodeInfo:for_each_child(callback)
    for child in self.node:iter_children() do
        callback(NodeInfo.new(self.buf, child))
    end
end

---@param position 'above'|'below'|'on'
---@return string
function NodeInfo:line(position)
    local start_row = nil
    if position == 'above' then
        start_row = self.start_row - 1
    elseif position == 'below' then
        start_row = self.end_row + 1
    else
        start_row = self.start_row
    end
    return vim.api.nvim_buf_get_lines(self.buf, start_row, start_row + 1, false)[1]
end

---@return string[]
function NodeInfo:lines()
    return vim.api.nvim_buf_get_lines(self.buf, self.start_row, self.end_row, false)
end

return NodeInfo
