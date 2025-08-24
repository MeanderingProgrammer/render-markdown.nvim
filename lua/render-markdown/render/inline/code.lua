local Base = require('render-markdown.render.base')
local colors = require('render-markdown.core.colors')

---@class render.md.render.inline.Code: render.md.Render
---@field private config render.md.code.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.code
    if not self.config.enabled then
        return false
    end
    if not self.config.inline then
        return false
    end
    return true
end

---@protected
function Render:run()
    local highlight = self.config.highlight_inline
    self.marks:over(self.config, 'code_background', self.node, {
        hl_group = highlight,
    })
    self:padding(highlight, true)
    self:padding(highlight, false)
end

---@private
---@param highlight string
---@param left boolean
function Render:padding(highlight, left)
    local line = self:line()
    local icon_highlight = colors.bg_as_fg(highlight)
    if left then
        line:text(self.config.inline_left, icon_highlight)
        line:pad(self.config.inline_pad, highlight)
    else
        line:pad(self.config.inline_pad, highlight)
        line:text(self.config.inline_right, icon_highlight)
    end
    if not line:empty() then
        local row = left and self.node.start_row or self.node.end_row
        local col = left and self.node.start_col or self.node.end_col
        self.marks:add(self.config, true, row, col, {
            priority = 0,
            virt_text = line:get(),
            virt_text_pos = 'inline',
        })
    end
end

return Render
