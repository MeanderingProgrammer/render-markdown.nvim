local Base = require('render-markdown.render.base')

---@class render.md.paragraph.Data
---@field margin number
---@field indent number

---@class render.md.render.Paragraph: render.md.Render
---@field private info render.md.paragraph.Config
---@field private data render.md.paragraph.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.paragraph
    if self.context:skip(self.info) then
        return false
    end
    local margin = self:get_number(self.info.left_margin)
    local indent = self:get_number(self.info.indent)
    if margin <= 0 and indent <= 0 then
        return false
    end
    self.data = { margin = margin, indent = indent }
    return true
end

---@private
---@param value render.md.paragraph.Number
---@return number
function Render:get_number(value)
    if type(value) == 'function' then
        return value({ text = self.node.text })
    else
        return value
    end
end

function Render:render()
    local width = math.max(vim.fn.max(self.node:widths()), self.info.min_width)
    local margin = self.context:percent(self.data.margin, width)
    self:padding(self.node.start_row, self.node.end_row - 1, margin)
    local indent = self.context:percent(self.data.indent, width)
    self:padding(self.node.start_row, self.node.start_row, indent)
end

---@private
---@param start_row integer
---@param end_row integer
---@param amount integer
function Render:padding(start_row, end_row, amount)
    local line = self.config:line():pad(amount):get()
    if #line == 0 then
        return
    end
    for row = start_row, end_row do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = line,
            virt_text_pos = 'inline',
        })
    end
end

return Render
