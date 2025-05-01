local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.colors')

---@class render.md.Render
---@field protected context render.md.Context
---@field protected config render.md.main.Config
---@field protected marks render.md.Marks
---@field protected node render.md.Node
---@field setup fun(self: render.md.Render): boolean
---@field render fun(self: render.md.Render)
local Base = {}
Base.__index = Base

---@param context render.md.Context
---@param marks render.md.Marks
---@param node render.md.Node
---@return render.md.Render
function Base:new(context, marks, node)
    local instance = setmetatable({}, self)
    instance.context = context
    instance.config = context.config
    instance.marks = marks
    instance.node = node
    return instance
end

---@protected
---@param enabled boolean
---@param text? string
---@param highlight? string
function Base:sign(enabled, text, highlight)
    local sign = self.config.sign
    if not sign.enabled or not enabled or not text then
        return
    end
    local sign_highlight = sign.highlight
    if highlight then
        sign_highlight = colors.combine(highlight, sign_highlight)
    end
    self.marks:start('sign', self.node, {
        sign_text = text,
        sign_hl_group = sign_highlight,
    })
end

---@protected
---@param icon string
---@param highlight string
---@return boolean
function Base:check_icon(icon, highlight)
    local line = self.config:line():text(icon, highlight)
    local space = self.context:width(self.node) + 1 - Str.width(icon)
    local right_pad = self.config.checkbox.right_pad
    if space < 0 then
        -- not enough space to fit the icon in-place
        return self.marks:over('check_icon', self.node, {
            virt_text = line:pad(right_pad):get(),
            virt_text_pos = 'inline',
            conceal = '',
        }, { 0, 0, 0, 1 })
    else
        local fits = math.min(space, right_pad)
        space = space - fits
        right_pad = right_pad - fits
        local row = self.node.start_row
        local start_col = self.node.start_col
        local end_col = self.node.end_col + 1
        self.marks:add('check_icon', row, start_col, {
            end_col = end_col - space,
            virt_text = line:pad(fits):get(),
            virt_text_pos = 'overlay',
        })
        if space > 0 then
            -- hide extra space after the icon
            self.marks:add('check_icon', row, end_col - space, {
                end_col = end_col,
                conceal = '',
            })
        end
        if right_pad > 0 then
            -- add padding
            self.marks:add('check_icon', row, end_col, {
                virt_text = self.config:line():pad(right_pad):get(),
                virt_text_pos = 'inline',
            })
        end
        return true
    end
end

---@protected
---@param element render.md.mark.Element
---@param node render.md.Node?
---@param highlight? string
function Base:scope(element, node, highlight)
    if not node or not highlight then
        return
    end
    self.marks:over(element, node:child('inline'), { hl_group = highlight })
end

---@protected
---@param virtual boolean
---@param level? integer
---@return render.md.Line
function Base:indent_line(virtual, level)
    if virtual then
        level = self:indent_level(level)
    else
        assert(level, 'level must be known for real lines')
    end
    local line = self.config:line()
    if level > 0 then
        local indent = self.config.indent
        local icon_width = Str.width(indent.icon)
        if icon_width == 0 then
            line:pad(indent.per_level * level)
        else
            for _ = 1, level do
                line:text(indent.icon, indent.highlight)
                line:pad(indent.per_level - icon_width)
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
    if not level then
        -- Level is not known, get it from the closest parent section
        level = self.node:level(true)
    else
        -- Level is known, must be a heading
        if indent.skip_heading then
            -- Account for ability to skip headings
            local parent = self.node:parent('section')
            level = parent and parent:level(true) or 0
        end
    end
    return math.max(level - indent.skip_level, 0)
end

return Base
