local Iter = require('render-markdown.core.iter')
local colors = require('render-markdown.colors')
local str = require('render-markdown.core.str')

---@class render.md.Renderer
---@field protected marks render.md.Marks
---@field protected config render.md.buffer.Config
---@field protected context render.md.Context
---@field protected info render.md.NodeInfo
---@field setup fun(self: render.md.Renderer): boolean
---@field render fun(self: render.md.Renderer)
local Base = {}
Base.__index = Base

---@param marks render.md.Marks
---@param config render.md.buffer.Config
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Base:new(marks, config, context, info)
    local instance = setmetatable({}, self)
    instance.marks = marks
    instance.config = config
    instance.context = context
    instance.info = info
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
    self.marks:add(false, self.info.start_row, self.info.start_col, {
        sign_text = text,
        sign_hl_group = sign_highlight,
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
        return str.width(a.pattern) < str.width(b.pattern)
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
        table.insert(line, 1, { str.pad(amount), self.config.padding.highlight })
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
        level = self.info:heading_level(true)
    elseif indent.skip_heading then
        local parent = self.info:parent('section')
        level = parent ~= nil and parent:heading_level(true) or 0
    end
    level = level - indent.skip_level
    if level <= 0 then
        return 0
    end
    return indent.per_level * level
end

return Base
