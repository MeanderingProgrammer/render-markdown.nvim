local Base = require('render-markdown.render.base')
local env = require('render-markdown.lib.env')

---@class render.md.paragraph.Data
---@field margin number
---@field indent number

---@class render.md.render.Paragraph: render.md.Render
---@field private config render.md.paragraph.Config
---@field private data render.md.paragraph.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.paragraph
    if self.context:skip(self.config) then
        return false
    end
    local margin = self:get_number(self.config.left_margin)
    local indent = self:get_number(self.config.indent)
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

---@protected
function Render:run()
    local widths = self.node:widths()
    local width = math.max(vim.fn.max(widths), self.config.min_width)
    local margin = env.win.percent(self.context.win, self.data.margin, width)
    self:padding(self.node.start_row, self.node.end_row - 1, margin)
    local indent = env.win.percent(self.context.win, self.data.indent, width)
    self:padding(self.node.start_row, self.node.start_row, indent)
end

---@private
---@param start_row integer
---@param end_row integer
---@param amount integer
function Render:padding(start_row, end_row, amount)
    local line = self:line():pad(amount):get()
    if #line == 0 then
        return
    end
    for row = start_row, end_row do
        self.marks:add(false, row, 0, {
            priority = 100,
            virt_text = line,
            virt_text_pos = 'inline',
        })
    end
end

return Render
