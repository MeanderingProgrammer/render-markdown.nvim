local context = require('render-markdown.context')
local str = require('render-markdown.str')

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
function M.info(node, source)
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

---@param infos render.md.NodeInfo[]
function M.sort_inplace(infos)
    table.sort(infos, function(info1, info2)
        if info1.start_row ~= info2.start_row then
            return info1.start_row < info2.start_row
        else
            return info1.start_col < info2.start_col
        end
    end)
end

---Walk through parent nodes, count the number of target nodes
---@param info render.md.NodeInfo
---@param target string
---@return integer
function M.level_in_section(info, target)
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
function M.parent(buf, info, target)
    local parent = info.node:parent()
    while parent ~= nil do
        if parent:type() == target then
            return M.info(parent, buf)
        end
        parent = parent:parent()
    end
    return nil
end

---@param buf integer
---@param info render.md.NodeInfo
---@param target string
---@return render.md.NodeInfo?
function M.sibling(buf, info, target)
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
---@param info? render.md.NodeInfo
---@param target_type string
---@param target_row? integer
---@return render.md.NodeInfo?
function M.child(buf, info, target_type, target_row)
    if info == nil then
        return nil
    end
    for child in info.node:iter_children() do
        if child:type() == target_type then
            if target_row == nil or child:range() == target_row then
                return M.info(child, buf)
            end
        end
    end
    return nil
end

---@param buf integer
---@param info? render.md.NodeInfo
---@return boolean
function M.hidden(buf, info)
    -- Missing nodes are considered hidden
    if info == nil then
        return true
    end
    return str.width(info.text) == M.concealed(buf, info)
end

---@param buf integer
---@param info render.md.NodeInfo
---@return integer
function M.concealed(buf, info)
    local ranges = context.get(buf):get_conceal(info.start_row)
    if #ranges == 0 then
        return 0
    end
    local result = 0
    local col = info.start_col
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

return M
