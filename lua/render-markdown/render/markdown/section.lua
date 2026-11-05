local Base = require('render-markdown.render.base')
local str = require('render-markdown.lib.str')

---@class render.md.indent.Data
---@field level_change integer

---@class render.md.render.Section: render.md.Render
---@field private config render.md.indent.Config
---@field private data render.md.indent.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.indent
    if not self.config.enabled then
        return false
    end
    local current_level = self.node:level(false)
    local parent_level = math.max(self.node:level(true), self.config.skip_level)
    local level_change = current_level - parent_level
    -- nothing to do if there is not a change in level
    if level_change <= 0 then
        return false
    end
    self.data = {
        level_change = level_change,
    }
    return true
end

---@protected
function Render:run()
    local start_row, end_row = self:rows()
    if self.config.innermost then
        -- inline marks at the same column have no reliable order, so each row
        -- gets a single mark with the full indent from the deepest section
        local level = self.node:level(false) - self.config.skip_level
        local indent = self:indent():line(false, math.max(level, 0))
        local line = indent:get()
        local blank = self:line():pad(indent:width()):get()
        local covered, quiet = self:children()
        for row = start_row, end_row do
            if not covered[row] then
                -- the empty line above the heading keeps the indent (a border
                -- may be drawn there) without the guide, so it starts with the
                -- heading
                local bare = quiet[row] or row < self.node.start_row
                self:add(row, bare and blank or line)
            end
        end
    else
        -- each level stacks inline marks so we only add changes in level
        local line = self:indent():line(false, self.data.level_change):get()
        for row = start_row, end_row do
            self:add(row, line)
        end
    end
end

---@private
---@return integer, integer
function Render:rows()
    local start_row = math.max(self.node.start_row + self:start_below(), 0)
    local end_row = self.node.end_row - 1 - self:end_above()
    return start_row, end_row
end

---@private
---@return table<integer, boolean>, table<integer, boolean>
function Render:children()
    -- rows marked by a nested section, and empty rows of a skipped nested
    -- heading this section marks without its guide
    local covered = {} ---@type table<integer, boolean>
    local quiet = {} ---@type table<integer, boolean>
    self.node:for_each_child(function(child)
        if child.type ~= 'section' then
            return
        end
        local render = setmetatable({}, Render)
        render.context = self.context
        render.marks = self.marks
        render.node = child
        if render:setup() then
            local start_row, end_row = render:rows()
            for row = start_row, end_row do
                covered[row] = true
            end
            for row = child.start_row + 1, start_row - 1 do
                local _, line = child:line('first', row - child.start_row)
                if str.width(line) == 0 then
                    quiet[row] = true
                end
            end
        end
    end)
    return covered, quiet
end

---@private
---@param row integer
---@param line render.md.mark.Line
function Render:add(row, line)
    self.marks:add(self.config, 'indent', row, 0, {
        priority = self.config.priority,
        virt_text = line,
        virt_text_pos = 'inline',
    })
end

---@private
---@return integer
function Render:start_below()
    if self.config.skip_heading then
        -- exclude second line of current section if empty
        local empty = self:empty('first', 1)
        return empty and 2 or 1
    else
        -- include last line of previous section if empty
        -- skip if it is the only line in the previous section
        local empty = self:empty('above', 1)
        local only = self:section('above', 2)
        return (empty and not only) and -1 or 0
    end
end

---@private
---@return integer
function Render:end_above()
    -- exclude last line of current section if empty
    -- skip if it is the only line in the last nested section
    local empty = self:empty('last', 0)
    local only = self:section('last', 1)
    return (empty and not only) and 1 or 0
end

---@private
---@param position render.md.node.Position
---@param by integer
---@return boolean
function Render:empty(position, by)
    local _, line = self.node:line(position, by)
    return str.width(line) == 0
end

---@private
---@param position render.md.node.Position
---@param by integer
---@return boolean
function Render:section(position, by)
    local _, line = self.node:line(position, by)
    return line and str.char_count(line, '#') > 0 or false
end

return Render
