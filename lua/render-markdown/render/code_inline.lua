local Base = require('render-markdown.render.base')

---@class render.md.render.CodeInline: render.md.Renderer
---@field private code render.md.Code
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.code = self.config.code
    if self.context:skip(self.code) then
        return false
    end
    if not vim.tbl_contains({ 'normal', 'full' }, self.code.style) then
        return false
    end
    return true
end

function Render:render()
    local highlight = self.code.highlight_inline
    self.marks:add_over('code_background', self.node, { hl_group = highlight })
    self:side_padding(highlight, self.node.start_row, self.node.start_col)
    self:side_padding(highlight, self.node.end_row, self.node.end_col)
end

---@private
---@param highlight string
---@param row integer
---@param col integer
function Render:side_padding(highlight, row, col)
    local padding = self.code.inline_pad
    if padding > 0 then
        self.marks:add(true, row, col, {
            priority = 0,
            virt_text = { self:padding_text(padding, highlight) },
            virt_text_pos = 'inline',
        })
    end
end

return Render
