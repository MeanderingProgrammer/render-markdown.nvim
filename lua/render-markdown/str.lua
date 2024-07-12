---@class render.md.StringHelper
local M = {}

---@param s string?
---@return integer
M.width = function(s)
    if s == nil then
        return 0
    end
    return vim.fn.strdisplaywidth(s)
end

---@param s string
---@return integer
M.leading_spaces = function(s)
    local _, leading_spaces = s:find('^%s*')
    return leading_spaces or 0
end

---@param value string
---@param s string
---@return string
M.pad_to = function(value, s)
    local padding = M.width(value) - M.width(s)
    return M.pad(s, padding)
end

---@param s string
---@param padding integer
---@return string
M.pad = function(s, padding)
    return string.rep(' ', padding) .. s
end

return M
