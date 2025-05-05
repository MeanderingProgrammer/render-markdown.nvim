local Base = require('render-markdown.render.base')
local Str = require('render-markdown.lib.str')

---@class render.md.checkbox.Data
---@field marker render.md.Node
---@field checkbox render.md.Node
---@field icon string
---@field highlight string
---@field scope_highlight? string

---@class render.md.render.Checkbox: render.md.Render
---@field private config render.md.checkbox.Config
---@field private data render.md.checkbox.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.checkbox
    if self.context:skip(self.config) then
        return false
    end
    local marker = self.node:child_at(0)
    if not marker then
        return false
    end
    local value = self:get_value(marker)
    if not value then
        return false
    end
    self.data = {
        marker = marker,
        checkbox = value.node,
        icon = value.config.icon,
        highlight = value.config.highlight,
        scope_highlight = value.config.scope_highlight,
    }
    return true
end

---@private
---@param marker render.md.Node
---@return render.md.request.checkbox.Value?
function Render:get_value(marker)
    local unchecked = marker:sibling('task_list_marker_unchecked')
    if unchecked then
        ---@type render.md.request.checkbox.Value
        return { node = unchecked, config = self.config.unchecked }
    end
    local checked = marker:sibling('task_list_marker_checked')
    if checked then
        ---@type render.md.request.checkbox.Value
        return { node = checked, config = self.config.checked }
    end
    return self.context.checkbox:get(self.node)
end

---@protected
function Render:run()
    self:marker()
    self:icon()
    self:scope()
end

---@private
function Render:marker()
    -- https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
    local node = self.data.marker
    local offset = { 0, Str.spaces('start', node.text), 0, 0 }
    self.marks:over('check_icon', node, { conceal = '' }, offset)
end

---@private
function Render:icon()
    local node = self.data.checkbox
    local line = self:line():text(self.data.icon, self.data.highlight)
    local space = self.context:width(node) + 1 - Str.width(self.data.icon)
    local right_pad = self.config.right_pad
    if space < 0 then
        -- not enough space to fit the icon in-place
        self.marks:over('check_icon', node, {
            virt_text = line:pad(right_pad):get(),
            virt_text_pos = 'inline',
            conceal = '',
        }, { 0, 0, 0, 1 })
    else
        local fits = math.min(space, right_pad)
        space = space - fits
        right_pad = right_pad - fits
        local row = node.start_row
        local start_col = node.start_col
        local end_col = node.end_col + 1
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
                virt_text = self:line():pad(right_pad):get(),
                virt_text_pos = 'inline',
            })
        end
    end
end

---@private
function Render:scope()
    local highlight = self.data.scope_highlight
    if not highlight then
        return
    end
    self.marks:over('check_scope', self.node:scope(), { hl_group = highlight })
end

return Render
