---@class render.md.Str
local M = {}

---@param s string
---@param sep string
---@param trimempty boolean
---@return string[]
function M.split(s, sep, trimempty)
    return vim.split(s, sep, { plain = true, trimempty = trimempty })
end

---number of hashtags at the start of the string
---@param s string
---@return integer
function M.level(s)
    local match = s:match('^%s*(#+)')
    return match and #match or 0
end

---@param s? string
---@return integer
function M.width(s)
    return s and vim.fn.strdisplaywidth(s) or 0
end

---@param line? render.md.mark.Line
---@return integer
function M.line_width(line)
    local result = 0
    for _, text in ipairs(line or {}) do
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
    return (from and to) and to - from + 1 or 0
end

---@param n integer
---@return string
function M.pad(n)
    return n > 0 and (' '):rep(n) or ''
end

return M
