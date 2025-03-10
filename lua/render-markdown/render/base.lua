local Iter = require('render-markdown.lib.iter')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.Renderer
---@field protected marks render.md.Marks
---@field protected config render.md.buffer.Config
---@field protected context render.md.Context
---@field protected node render.md.Node
---@field setup fun(self: render.md.Renderer): boolean
---@field render fun(self: render.md.Renderer)
local Base = {}
Base.__index = Base

---@param marks render.md.Marks
---@param config render.md.buffer.Config
---@param context render.md.Context
---@param node render.md.Node
---@return render.md.Renderer
function Base:new(marks, config, context, node)
    local instance = setmetatable({}, self)
    instance.marks = marks
    instance.config = config
    instance.context = context
    instance.node = node
    return instance
end

---@protected
---@param text? string
---@param highlight? string
function Base:sign(text, highlight)
    local sign = self.config.sign
    if not sign.enabled or text == nil then
        return
    end
    local sign_highlight = sign.highlight
    if highlight ~= nil then
        sign_highlight = colors.combine(highlight, sign_highlight)
    end
    self.marks:add('sign', self.node.start_row, self.node.start_col, {
        sign_text = text,
        sign_hl_group = sign_highlight,
    })
end

---@protected
---@param element boolean|render.md.Element
---@param node render.md.Node?
---@param highlight? string
function Base:scope(element, node, highlight)
    if node == nil or highlight == nil then
        return
    end
    local inline = node:child('inline')
    if inline == nil then
        return
    end
    self.marks:add_over(element, inline, { hl_group = highlight })
end

---@protected
---@param icon string
---@param highlight string
---@param destination string
---@return string, string
function Base:from_destination(icon, highlight, destination)
    local components = Iter.table.filter(self.config.link.custom, function(component)
        return destination:find(component.pattern) ~= nil
    end)
    table.sort(components, function(a, b)
        return Str.width(a.pattern) < Str.width(b.pattern)
    end)
    local component = components[#components] or {}
    return component.icon or icon, component.highlight or highlight
end

---@protected
---@param virtual boolean
---@param level? integer
---@return render.md.MarkLine
function Base:indent_line(virtual, level)
    if virtual then
        level = self:indent_level(level)
    else
        assert(level ~= nil, 'Level must be known for real lines')
    end
    local line = {}
    if level > 0 then
        local indent = self.config.indent
        local icon_width = Str.width(indent.icon)
        if icon_width == 0 then
            self:append(line, indent.per_level * level)
        else
            for _ = 1, level do
                self:append(line, indent.icon, indent.highlight)
                self:append(line, indent.per_level - icon_width)
            end
        end
    end
    return line
end

---@protected
---@param level? integer
---@return integer
function Base:indent_size(level)
    return self.config.indent.per_level * self:indent_level(level)
end

---@private
---@param level? integer
---@return integer
function Base:indent_level(level)
    local indent = self.config.indent
    if self.context:skip(indent) then
        return 0
    end
    if level == nil then
        -- Level is not known, get it from the closest parent section
        level = self.node:level(true)
    else
        -- Level is known, must be a heading
        if indent.skip_heading then
            -- Account for ability to skip headings
            local parent = self.node:parent('section')
            level = parent ~= nil and parent:level(true) or 0
        end
    end
    return math.max(level - indent.skip_level, 0)
end

---@protected
---@param line render.md.MarkLine
---@param value string|integer
---@param highlight? string|string[]
---@return render.md.MarkLine
function Base:append(line, value, highlight)
    highlight = highlight or self.config.padding.highlight
    if type(value) == 'string' then
        if #value > 0 then
            table.insert(line, { value, highlight })
        end
    else
        if value > 0 then
            table.insert(line, { Str.pad(value), highlight })
        end
    end
    return line
end

return Base
