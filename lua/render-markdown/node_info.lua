local context = require('render-markdown.context')
local str = require('render-markdown.str')

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

---@return string[]
function NodeInfo:lines()
    local end_row = self.end_row
    if end_row == self.start_row then
        end_row = end_row + 1
    end
    return vim.api.nvim_buf_get_lines(self.buf, self.start_row, end_row, false)
end

---@return boolean
function NodeInfo:hidden()
    return str.width(self.text) == self:concealed()
end

---@return integer
function NodeInfo:concealed()
    local ranges = context.get(self.buf):get_conceal(self.start_row)
    if #ranges == 0 then
        return 0
    end
    local result = 0
    local col = self.start_col
    for _, index in ipairs(vim.fn.str2list(self.text)) do
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

return NodeInfo
