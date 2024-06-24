---@param node TSNode
---@return boolean
local function in_section(node)
    -- reaching a section or document means we are outside section
    return not vim.tbl_contains({ 'section', 'document' }, node:type())
end

local M = {}

---Walk through parent nodes, count the number of target nodes
---@param node TSNode
---@param target string
---@return integer
M.level_in_section = function(node, target)
    local level = 0
    local parent = node:parent()
    while parent ~= nil and in_section(parent) do
        if parent:type() == target then
            level = level + 1
        end
        parent = parent:parent()
    end
    return level
end

---Walk through parent nodes, return first target node
---@param node TSNode
---@param target string
---@return TSNode?
M.parent_in_section = function(node, target)
    local parent = node:parent()
    while parent ~= nil and in_section(parent) do
        if parent:type() == target then
            return parent
        end
        parent = parent:parent()
    end
    return nil
end

---@param node TSNode
---@param targets string[]
---@return TSNode?
M.sibling = function(node, targets)
    local sibling = node:next_sibling()
    while sibling ~= nil do
        if vim.tbl_contains(targets, sibling:type()) then
            return sibling
        end
        sibling = sibling:next_sibling()
    end
    return nil
end

---@param node TSNode
---@param target string
---@return TSNode?
M.child = function(node, target)
    for child in node:iter_children() do
        if child:type() == target then
            return child
        end
    end
    return nil
end

---@param buf integer
---@param row integer
---@param s string
---@return integer
M.concealed = function(buf, row, s)
    local result = 0
    local col = 0
    for _, index in ipairs(vim.fn.str2list(s)) do
        local ch = vim.fn.nr2char(index)
        local captures = vim.treesitter.get_captures_at_pos(buf, row, col)
        for _, capture in ipairs(captures) do
            if capture.metadata.conceal ~= nil then
                result = result + vim.fn.strdisplaywidth(ch)
            end
        end
        col = col + #ch
    end
    return result
end

return M
