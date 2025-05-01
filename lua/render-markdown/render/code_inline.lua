local Base = require('render-markdown.render.base')
local colors = require('render-markdown.colors')

---@class render.md.render.CodeInline: render.md.Render
---@field private info render.md.code.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.code
    if self.context:skip(self.info) then
        return false
    end
    if not vim.tbl_contains({ 'normal', 'full' }, self.info.style) then
        return false
    end
    return true
end

function Render:render()
    local highlight = self.info.highlight_inline
    self.marks:over('code_background', self.node, { hl_group = highlight })
    self:padding(highlight, true)
    self:padding(highlight, false)
end

---@private
---@param highlight string
---@param left boolean
function Render:padding(highlight, left)
    local line = self.config:line()
    local icon_highlight = colors.bg_as_fg(highlight)
    if left then
        line:text(self.info.inline_left, icon_highlight)
        line:pad(self.info.inline_pad, highlight)
    else
        line:pad(self.info.inline_pad, highlight)
        line:text(self.info.inline_right, icon_highlight)
    end
    if not line:empty() then
        local row = left and self.node.start_row or self.node.end_row
        local col = left and self.node.start_col or self.node.end_col
        self.marks:add(true, row, col, {
            priority = 0,
            virt_text = line:get(),
            virt_text_pos = 'inline',
        })
    end
end

return Render
