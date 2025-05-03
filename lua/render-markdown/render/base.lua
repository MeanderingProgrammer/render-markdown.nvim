local Indent = require('render-markdown.lib.indent')
local Str = require('render-markdown.lib.str')
local colors = require('render-markdown.core.colors')

---@class render.md.Render
---@field protected context render.md.request.Context
---@field protected config render.md.main.Config
---@field protected marks render.md.Marks
---@field protected node render.md.Node
---@field setup fun(self: render.md.Render): boolean
---@field render fun(self: render.md.Render)
local Base = {}
Base.__index = Base

---@param context render.md.request.Context
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
---@return render.md.Indent
function Base:indent()
    return Indent.new(self.context, self.node)
end

---@protected
---@param enabled boolean
---@param text? string
---@param highlight? string
function Base:sign(enabled, text, highlight)
    local config = self.config.sign
    if not config.enabled or not enabled or not text then
        return
    end
    local sign_highlight = config.highlight
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

return Base
