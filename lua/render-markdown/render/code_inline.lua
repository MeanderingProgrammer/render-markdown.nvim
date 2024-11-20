local Base = require('render-markdown.render.base')

---@class render.md.render.CodeInline: render.md.Renderer
---@field private code render.md.Code
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.code = self.config.code
    if not self.code.enabled or not vim.tbl_contains({ 'normal', 'full' }, self.code.style) then
        return false
    end
    return true
end

function Render:render()
    self.marks:add_over('code_background', self.node, {
        hl_group = self.code.highlight_inline,
    })
end

return Render
