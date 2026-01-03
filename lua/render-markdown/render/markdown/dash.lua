local Base = require('render-markdown.render.base')
local env = require('render-markdown.lib.env')

---@class render.md.dash.Data
---@field width integer
---@field margin integer

---@class render.md.render.Dash: render.md.Render
---@field private config render.md.dash.Config
---@field private data render.md.dash.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.dash
    if not self.config.enabled then
        return false
    end
    local width = self:get_width(self.config.width, 0)
    local margin = self:get_width(self.config.left_margin, width)
    if width <= 0 then
        return false
    end
    self.data = { width = width, margin = margin }
    return true
end

---@private
---@param width render.md.dash.Width
---@param used integer
---@return integer
function Render:get_width(width, used)
    if type(width) == 'number' then
        return env.win.percent(self.context.win, width, used)
    elseif type(width) == 'function' then
        return width({ width = env.win.width(self.context.win) })
    else
        return vim.o.columns
    end
end

---@protected
function Render:run()
    local line = self:line():pad(self.data.margin)
    line:rep(self.config.icon, self.data.width, self.config.highlight)
    local start_row, end_row = self.node.start_row, self.node.end_row - 1
    self:dash(line, start_row)
    if end_row > start_row then
        self:dash(line, end_row)
    end
end

---@param line render.md.Line
---@param row integer
function Render:dash(line, row)
    self.marks:add(self.config, 'dash', row, 0, {
        priority = self.config.priority,
        virt_text = line:get(),
        virt_text_pos = 'overlay',
    })
end

return Render
