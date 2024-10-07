local Base = require('render-markdown.render.base')
local Iter = require('render-markdown.core.iter')
local str = require('render-markdown.core.str')

---@class render.md.render.Paragraph: render.md.Renderer
---@field private paragraph render.md.Paragraph
local Render = setmetatable({}, Base)
Render.__index = Render

---@param marks render.md.Marks
---@param config render.md.buffer.Config
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Render:new(marks, config, context, info)
    return Base.new(self, marks, config, context, info)
end

---@return boolean
function Render:setup()
    self.paragraph = self.config.paragraph
    return self.paragraph.enabled and self.paragraph.left_margin > 0
end

function Render:render()
    local width = vim.fn.max(Iter.list.map(self.info:lines(), str.width))
    width = math.max(width, self.paragraph.min_width)
    local margin = self.context:resolve_offset(self.paragraph.left_margin, width)
    if margin <= 0 then
        return
    end

    local virt_text = { { str.pad(margin), self.config.padding.highlight } }
    for row = self.info.start_row, self.info.end_row - 1 do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = virt_text,
            virt_text_pos = 'inline',
        })
    end
end

return Render
