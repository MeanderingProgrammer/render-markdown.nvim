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
    local parent_level = math.max(self.info:heading_level(true), self.indent.skip_level)
    self.level_change = current_level - parent_level

    -- Nothing to do if there is not a change in level
    if self.level_change <= 0 then
        return false
    end

    return true
end

function Render:render()
    local start_row = nil
    if self.indent.skip_heading then
        -- Exclude any lines potentially used by section heading
        local second = self.info:line('first', 1)
        local start_offset = str.width(second) == 0 and 1 or 0
        start_row = self.info.start_row + 1 + start_offset
    else
        -- Include last empty line in previous section
        -- Exclude if it is the only empty line in that section
        local above, two_above = self.info:line('above', 1), self.info:line('above', 2)
        local above_is_empty = str.width(above) == 0
        local two_above_is_section = two_above ~= nil and vim.startswith(two_above, '#')
        local start_offset = (above_is_empty and not two_above_is_section) and 1 or 0
        start_row = math.max(self.info.start_row - start_offset, 0)
    end

    -- Exclude last empty line in current section
    -- Include if it is the only empty line of the last subsection
    local last, second_last = self.info:line('last', 0), self.info:line('last', 1)
    local last_is_empty = str.width(last) == 0
    local second_last_is_section = second_last ~= nil and vim.startswith(second_last, '#')
    local end_offset = (last_is_empty and not second_last_is_section) and 1 or 0
    local end_row = self.info.end_row - 1 - end_offset

    -- Each level stacks inline marks so we only need to multiply based on any skipped levels
    for row = start_row, end_row do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = { { str.pad(self.indent.per_level * self.level_change), self.config.padding.highlight } },
            virt_text_pos = 'inline',
        })
    end
end

return Render
