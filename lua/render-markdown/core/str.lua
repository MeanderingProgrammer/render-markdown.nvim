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

---@param s string
---@return integer
function M.leading_spaces(s)
    local _, leading_spaces = s:find('^%s*')
    return leading_spaces or 0
end

---@param n integer
---@return string
function M.spaces(n)
    return string.rep(' ', n)
end

---@param target string
---@param s string
---@return string
function M.pad_to(target, s)
    local n = M.width(target) - M.width(s)
    return M.pad(n, s)
end

---@param n integer
---@param s string
---@return string
function M.pad(n, s)
    return M.spaces(n) .. s
end

return M
