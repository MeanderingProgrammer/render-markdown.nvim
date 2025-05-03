local Str = require('render-markdown.lib.str')

---@class render.md.Indent
---@field private context render.md.request.Context
---@field private config render.md.indent.Config
---@field private node render.md.Node
local Indent = {}
Indent.__index = Indent

---@param context render.md.request.Context
---@param node render.md.Node
---@return render.md.Indent
function Indent.new(context, node)
    local self = setmetatable({}, Indent)
    self.context = context
    self.config = context.config.indent
    self.node = node
    return self
end

---@param virtual boolean
---@param level? integer
---@return render.md.Line
function Indent:line(virtual, level)
    if virtual then
        level = self:level(level)
    else
        assert(level, 'level must be known for non-virtual lines')
    end
    local line = self.context.config:line()
    if level > 0 then
        local icon_width = Str.width(self.config.icon)
        if icon_width == 0 then
            line:pad(self.config.per_level * level)
        else
            for _ = 1, level do
                line:text(self.config.icon, self.config.highlight)
                line:pad(self.config.per_level - icon_width)
            end
        end
    end
    return line
end

---@param level? integer
---@return integer
function Indent:size(level)
    return self.config.per_level * self:level(level)
end

---@private
---@param level? integer
---@return integer
function Indent:level(level)
    if self.context:skip(self.config) then
        return 0
    end
    if not level then
        -- level is unknown, get it from parent section
        level = self.node:level(true)
    else
        -- level is known, must be a heading
        if self.config.skip_heading then
            -- account for ability to skip indenting headings
            local parent = self.node:parent('section')
            level = parent and parent:level(true) or 0
        end
    end
    return math.max(level - self.config.skip_level, 0)
end

return Indent
