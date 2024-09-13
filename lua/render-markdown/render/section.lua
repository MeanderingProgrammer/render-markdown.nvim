local Base = require('render-markdown.render.base')
local str = require('render-markdown.core.str')

---@class render.md.render.Section: render.md.Renderer
---@field private indent render.md.Indent
---@field private level_change integer
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
    self.indent = self.config.indent
    if not self.indent.enabled then
        return false
    end

    local current_level = self.info:heading_level(false)
    local parent_level = math.max(self.info:heading_level(true), self.indent.skip)
    self.level_change = current_level - parent_level

    -- Nothing to do if there is not a change in level
    if self.level_change <= 0 then
        return false
    end

    return true
end

function Render:render()
    -- Do include empty line in previous section
    local start_offset = str.width(self.info:line('above')) == 0 and 1 or 0
    local start_row = math.max(self.info.start_row - start_offset, 0)

    -- Do not include empty line at the end of current section
    local end_offset = str.width(self.info:line('last')) == 0 and 1 or 0
    local end_row = self.info.end_row - 1 - end_offset

    -- Each level stacks inline marks so we only need to multiply based on any skipped levels
    for row = start_row, end_row do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = { { str.spaces(self.indent.per_level * self.level_change), 'Normal' } },
            virt_text_pos = 'inline',
        })
    end
end

return Render
