local M = {}

---@param value string
---@param s string
---@return string
M.pad_to = function(value, s)
    local padding = vim.fn.strdisplaywidth(value) - vim.fn.strdisplaywidth(s)
    return M.pad(s, padding)
end

---@param s string
---@param padding integer?
---@return string
M.pad = function(s, padding)
    return string.rep(' ', padding or 0) .. s
end

return M
