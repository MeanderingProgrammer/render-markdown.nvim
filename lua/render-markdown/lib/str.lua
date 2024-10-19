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

return M
