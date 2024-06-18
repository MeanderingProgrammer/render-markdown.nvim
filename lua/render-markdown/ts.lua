local M = {}

---@param node TSNode
---@param targets string[]
---@return boolean
M.is_sibling = function(node, targets)
    local sibling = node:next_sibling()
    if sibling == nil then
        return false
    end
    return vim.tbl_contains(targets, sibling:type())
end

--- Walk through all parent nodes and count the number of list nodes
---@param node TSNode
---@return integer
M.get_list_level = function(node)
    local level = 0
    local parent = node:parent()
    while parent ~= nil do
        local parent_type = parent:type()
        if vim.tbl_contains({ 'section', 'document' }, parent_type) then
            -- reaching a section or document means we are clearly at the top of the list
            break
        elseif parent_type == 'list' then
            -- found a list increase the level and continue
            level = level + 1
        end
        parent = parent:parent()
    end
    return level
end

--- Walk through parent nodes until target, return first found
---@param node TSNode
---@param target string
---@return TSNode?
M.get_parent = function(node, target)
    local parent = node:parent()
    while parent ~= nil do
        local parent_type = parent:type()
        if vim.tbl_contains({ 'section', 'document' }, parent_type) then
            -- reaching a section or document means we are clearly outside our target
            break
        elseif parent_type == target then
            return parent
        end
        parent = parent:parent()
    end
    return nil
end

---@param node TSNode
---@param target string
---@return TSNode?
M.get_child = function(node, target)
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
