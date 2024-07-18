local str = require('render-markdown.str')
local util = require('render-markdown.util')

---@param node TSNode
---@return boolean
local function in_section(node)
    -- reaching a section or document means we are outside section
    return not vim.tbl_contains({ 'section', 'document' }, node:type())
end

---@class render.md.TSHelper
local M = {}

---@class render.md.NodeInfo
---@field node TSNode
---@field type string
---@field text string
---@field start_row integer
---@field start_col integer
---@field end_row integer
---@field end_col integer

---@param node TSNode
---@param source integer|string
---@return render.md.NodeInfo
M.info = function(node, source)
    local start_row, start_col, end_row, end_col = node:range()
    ---@type render.md.NodeInfo
    return {
        node = node,
        type = node:type(),
        text = vim.treesitter.get_node_text(node, source),
        start_row = start_row,
        start_col = start_col,
        end_row = end_row,
        end_col = end_col,
    }
end

---Walk through parent nodes, count the number of target nodes
---@param info render.md.NodeInfo
---@param target string
---@return integer
M.level_in_section = function(info, target)
    local level = 0
    local parent = info.node:parent()
    while parent ~= nil and in_section(parent) do
        if parent:type() == target then
            level = level + 1
        end
        parent = parent:parent()
    end
    return level
end

---@param buf integer
---@param info render.md.NodeInfo
---@param target string
---@return render.md.NodeInfo?
M.sibling = function(buf, info, target)
    local sibling = info.node:next_sibling()
    while sibling ~= nil do
        if sibling:type() == target then
            return M.info(sibling, buf)
        end
        sibling = sibling:next_sibling()
    end
    return nil
end

---@param buf integer
---@param info render.md.NodeInfo
---@param target_type string
---@param target_row integer
---@return render.md.NodeInfo?
M.child = function(buf, info, target_type, target_row)
    for child in info.node:iter_children() do
        if child:type() == target_type then
            if child:range() == target_row then
                return M.info(child, buf)
            end
        end
    end
    return nil
end

---@param buf integer
---@param info? render.md.NodeInfo
---@return boolean
M.hidden = function(buf, info)
    -- Missing nodes are considered hidden
    if info == nil then
        return true
    end
    return str.width(info.text) == M.concealed(buf, info)
end

---@param buf integer
---@param info render.md.NodeInfo
---@return integer
M.concealed = function(buf, info)
    if util.get_win(util.buf_to_win(buf), 'conceallevel') == 0 then
        return 0
    end
    local result = 0
    local col = info.start_col
    for _, index in ipairs(vim.fn.str2list(info.text)) do
        local ch = vim.fn.nr2char(index)
        local captures = vim.treesitter.get_captures_at_pos(buf, info.start_row, col)
        for _, capture in ipairs(captures) do
            if capture.metadata.conceal ~= nil then
                result = result + str.width(ch)
            end
        end
        col = col + #ch
    end
    return result
end

return M
