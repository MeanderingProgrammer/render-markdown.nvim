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
    self:side_padding(highlight, true)
    self:side_padding(highlight, false)
end

---@private
---@param highlight string
---@param left boolean
function Render:side_padding(highlight, left)
    local line, icon_highlight = {}, colors.bg_to_fg(highlight)
    if left then
        self:append(line, self.info.inline_left, icon_highlight)
        self:append(line, self.info.inline_pad, highlight)
    else
        self:append(line, self.info.inline_pad, highlight)
        self:append(line, self.info.inline_right, icon_highlight)
    end
    if #line > 0 then
        local row = left and self.node.start_row or self.node.end_row
        local col = left and self.node.start_col or self.node.end_col
        self.marks:add(true, row, col, {
            priority = 0,
            virt_text = line,
            virt_text_pos = 'inline',
        })
    end
end

return Render
