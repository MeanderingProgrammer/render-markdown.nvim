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

---@param line? render.md.mark.Line
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
    if n <= 0 then
        return ''
    end
    return string.rep(' ', n)
end

return M
