---@class render.md.StringHelper
local M = {}

---@param s string?
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

---@param value string
---@param s string
---@return string
function M.pad_to(value, s)
    local padding = M.width(value) - M.width(s)
    return M.pad(padding, s)
end

---@param padding integer
---@param s string?
---@return string
function M.pad(padding, s)
    local result = string.rep(' ', padding)
    if s ~= nil then
        result = result .. s
    end
    return result
end

return M
