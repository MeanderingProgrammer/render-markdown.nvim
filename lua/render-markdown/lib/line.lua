local interval = require('render-markdown.lib.interval')
local str = require('render-markdown.lib.str')

---@class render.md.Line
---@field private highlight string
---@field private line render.md.mark.Line
local Line = {}
Line.__index = Line

---@param highlight string
---@return render.md.Line
function Line.new(highlight)
    local self = setmetatable({}, Line)
    self.highlight = highlight
    self.line = {}
    return self
end

---@return render.md.mark.Line
function Line:get()
    return self.line
end

---@return boolean
function Line:empty()
    return #self.line == 0
end

---@return integer
function Line:width()
    return str.line_width(self.line)
end

---@param other render.md.Line
---@return render.md.Line
function Line:extend(other)
    vim.list_extend(self.line, other.line)
    return self
end

---@return render.md.Line
function Line:copy()
    return Line.new(self.highlight):extend(self)
end

---@param i integer 1-based inclusive
---@param j integer 1-based inclusive
---@return render.md.Line
function Line:sub(i, j)
    local result = Line.new(self.highlight)
    local position = 0
    for _, text in ipairs(self.line) do
        local length = str.width(text[1])
        local range = { i - position, j - position } ---@type render.md.Range
        local overlap = interval.overlap({ 1, length }, range)
        if overlap then
            result:add(str.sub(text[1], overlap[1], overlap[2]), text[2])
        end
        position = position + length
    end
    return result
end

---@param s string
---@param highlight? render.md.mark.Hl
---@return render.md.Line
function Line:text(s, highlight)
    if #s > 0 then
        self:add(s, highlight)
    end
    return self
end

---@param n integer
---@param highlight? render.md.mark.Hl
---@return render.md.Line
function Line:pad(n, highlight)
    return self:rep(' ', n, highlight)
end

---@param s string
---@param n integer
---@param highlight? render.md.mark.Hl
---@return render.md.Line
function Line:rep(s, n, highlight)
    if n > 0 then
        self:add(s:rep(n), highlight)
    end
    return self
end

---@private
---@param text string
---@param highlight? render.md.mark.Hl
function Line:add(text, highlight)
    self.line[#self.line + 1] = { text, highlight or self.highlight }
end

return Line
