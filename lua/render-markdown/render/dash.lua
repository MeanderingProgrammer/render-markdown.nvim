local Base = require('render-markdown.render.base')

---@class render.md.render.Dash: render.md.Renderer
---@field private dash render.md.Dash
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
    self.dash = self.config.dash
    if not self.dash.enabled then
        return false
    end
    return true
end

function Render:render()
    local width = self.dash.width
    width = type(width) == 'number' and width or self.context:get_width()

    self.marks:add(true, self.info.start_row, 0, {
        virt_text = { { self.dash.icon:rep(width), self.dash.highlight } },
        virt_text_pos = 'overlay',
    })
end

return Render
