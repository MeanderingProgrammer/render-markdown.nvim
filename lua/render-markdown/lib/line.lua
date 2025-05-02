---@class render.md.Line
---@field private highlight string
---@field private line render.md.mark.Line
local Line = {}
Line.__index = Line

---@param config render.md.main.Config
---@return render.md.Line
function Line.new(config)
    local self = setmetatable({}, Line)
    self.highlight = config.padding.highlight
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

---@param other render.md.Line
---@return render.md.Line
function Line:extend(other)
    vim.list_extend(self.line, other.line)
    return self
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
    if n > 0 then
        self:add((' '):rep(n), highlight)
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
