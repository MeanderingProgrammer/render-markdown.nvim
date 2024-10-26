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
---@param paragraph render.md.Node?
---@param highlight? string
function Base:checkbox_scope(paragraph, highlight)
    if paragraph == nil or highlight == nil then
        return
    end
    paragraph = paragraph:child('inline')
    if paragraph == nil then
        return
    end
    self.marks:add('check_scope', paragraph.start_row, paragraph.start_col, {
        end_row = paragraph.end_row,
        end_col = paragraph.end_col,
        hl_group = highlight,
    })
end

---@protected
---@param destination string
---@return render.md.LinkComponent?
function Base:link_component(destination)
    local link = self.config.link
    local link_components = Iter.table.filter(link.custom, function(link_component)
        return destination:find(link_component.pattern) ~= nil
    end)
    table.sort(link_components, function(a, b)
        return Str.width(a.pattern) < Str.width(b.pattern)
    end)
    return link_components[#link_components]
end

---@protected
---@param line { [1]: string, [2]: string }[]
---@param level? integer
---@return { [1]: string, [2]: string }[]
function Base:indent_virt_line(line, level)
    local amount = self:indent(level)
    if amount > 0 then
        table.insert(line, 1, { Str.pad(amount), self.config.padding.highlight })
    end
    return line
end

---@protected
---@param level? integer
---@return integer
function Base:indent(level)
    local indent = self.config.indent
    if not indent.enabled then
        return 0
    end
    if level == nil then
        level = self.node:heading_level(true)
    elseif indent.skip_heading then
        local parent = self.node:parent('section')
        level = parent ~= nil and parent:heading_level(true) or 0
    end
    level = level - indent.skip_level
    if level <= 0 then
        return 0
    end
    return indent.per_level * level
end

return Base
