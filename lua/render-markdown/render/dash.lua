local Base = require('render-markdown.render.base')

---@class render.md.render.Dash: render.md.Render
---@field private info render.md.dash.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.dash
    if self.context:skip(self.info) then
        return false
    end
    return true
end

function Render:render()
    local width = self.info.width
    width = type(width) == 'number' and self.context:percent(width, 0)
        or vim.o.columns
    local margin = self.context:percent(self.info.left_margin, width)

    local line = self.config:line():pad(margin)
    line:text(self.info.icon:rep(width), self.info.highlight)

    local start_row, end_row = self.node.start_row, self.node.end_row - 1
    self:dash(line, start_row)
    if end_row > start_row then
        self:dash(line, end_row)
    end
end

---@param line render.md.Line
---@param row integer
function Render:dash(line, row)
    self.marks:add('dash', row, 0, {
        virt_text = line:get(),
        virt_text_pos = 'overlay',
    })
end

return Render
