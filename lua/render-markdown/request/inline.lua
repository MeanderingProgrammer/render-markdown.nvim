local str = require('render-markdown.lib.str')

---@class render.md.request.inline.Value
---@field col integer
---@field line render.md.mark.Line

---@class render.md.request.Inline
---@field private values table<integer, render.md.request.inline.Value[]>
local Inline = {}
Inline.__index = Inline

---@return render.md.request.Inline
function Inline.new()
    local self = setmetatable({}, Inline)
    self.values = {}
    return self
end

---@param row integer
---@param value render.md.request.inline.Value
function Inline:add(row, value)
    if #value.line == 0 then
        return
    end
    if not self.values[row] then
        self.values[row] = {}
    end
    local values = self.values[row]
    values[#values + 1] = value
end

---@param body render.md.node.Body
---@return integer
function Inline:width(body)
    local result = 0
    for _, value in ipairs(self:get(body)) do
        result = result + str.line_width(value.line)
    end
    return result
end

---@param body render.md.node.Body
---@return render.md.request.inline.Value[]
function Inline:get(body)
    return self:range(body.start_row, body.start_col, body.end_col)
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.request.inline.Value[]
function Inline:range(row, start_col, end_col)
    local result = {} ---@type render.md.request.inline.Value[]
    local values = self.values[row] or {}
    for _, value in ipairs(values) do
        if start_col <= value.col and end_col > value.col then
            result[#result + 1] = value
        end
    end
    table.sort(result, function(a, b)
        return a.col < b.col
    end)
    return result
end

return Inline
