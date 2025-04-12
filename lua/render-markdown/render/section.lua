local Base = require('render-markdown.render.base')
local Str = require('render-markdown.lib.str')

---@class render.md.render.Section: render.md.Render
---@field private info render.md.indent.Config
---@field private level_change integer
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.indent
    if self.context:skip(self.info) then
        return false
    end

    local current_level = self.node:level(false)
    local parent_level = math.max(self.node:level(true), self.info.skip_level)
    self.level_change = current_level - parent_level

    -- Nothing to do if there is not a change in level
    if self.level_change <= 0 then
        return false
    end

    return true
end

function Render:render()
    local start_row = self:get_start_row()
    local end_row = self:get_end_row()
    -- Each level stacks inline marks so we only need to process change in level
    local virt_text = self:indent_line(false, self.level_change)
    for row = start_row, end_row do
        self.marks:add(false, row, 0, {
            priority = 0,
            virt_text = virt_text,
            virt_text_pos = 'inline',
        })
    end
end

---@private
---@return integer
function Render:get_start_row()
    if self.info.skip_heading then
        -- Exclude any lines potentially used by section heading
        local second = self.node:line('first', 1)
        local offset = Str.width(second) == 0 and 1 or 0
        return self.node.start_row + 1 + offset
    else
        -- Include last empty line in previous section
        -- Exclude if it is the only empty line in that section
        local above = self.node:line('above', 1)
        local two_above = self.node:line('above', 2)
        local above_is_empty = Str.width(above) == 0
        local two_above_is_section = self:is_section(two_above)
        local offset = (above_is_empty and not two_above_is_section) and 1 or 0
        return math.max(self.node.start_row - offset, 0)
    end
end

---@private
---@return integer
function Render:get_end_row()
    -- Exclude last empty line in current section
    -- Include if it is the only empty line of the last subsection
    local last = self.node:line('last', 0)
    local second_last = self.node:line('last', 1)
    local last_is_empty = Str.width(last) == 0
    local second_last_is_section = self:is_section(second_last)
    local offset = (last_is_empty and not second_last_is_section) and 1 or 0
    return self.node.end_row - 1 - offset
end

---@private
---@param line? string
---@return boolean
function Render:is_section(line)
    return line ~= nil and vim.startswith(line, '#')
end

return Render
