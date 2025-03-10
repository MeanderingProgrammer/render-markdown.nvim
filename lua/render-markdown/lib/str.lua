---@class render.md.StringHelper
local M = {}

---@param s string
---@param sep string
---@return string[]
function M.split(s, sep)
    return vim.split(s, sep, { plain = true, trimempty = true })
end

---@param s? string
---@return integer
function M.width(s)
    if s == nil then
        return 0
    end
    return vim.fn.strdisplaywidth(s)
end

---@param line? render.md.MarkLine
---@return integer
function M.line_width(line)
    if line == nil then
        return 0
    end
    local result = 0
    for _, text in ipairs(line) do
        result = result + M.width(text[1])
    end
    return result
end

---@param pos 'start'|'end'
---@param s string
---@return integer
function M.spaces(pos, s)
    local pattern = pos == 'start' and '^%s*' or '%s*$'
    local from, to = s:find(pattern)
    return (from ~= nil and to ~= nil) and to - from + 1 or 0
end

---@param n integer
---@return string
function M.pad(n)
    return string.rep(' ', n)
end

---@param target string
---@param s string
---@return string
function M.pad_to(target, s)
    return M.pad(M.width(target) - M.width(s))
end

---@param s string
---@param pattern string
---@return Range2[]
function M.find_all(s, pattern)
    local result = {}
    ---@type integer?
    local index = 1
    while index ~= nil do
        local start_index, end_index = s:find(pattern, index)
        if start_index == nil or end_index == nil then
            index = nil
        else
            table.insert(result, { start_index, end_index })
            index = end_index + 1
        end
    end
    return result
end

return M
