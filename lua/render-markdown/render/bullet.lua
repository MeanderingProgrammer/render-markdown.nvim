local Base = require('render-markdown.render.base')
local List = require('render-markdown.lib.list')
local Str = require('render-markdown.lib.str')

---@class render.md.bullet.Data
---@field marker render.md.Node
---@field spaces integer
---@field checkbox? render.md.checkbox.custom.Config

---@class render.md.render.Bullet: render.md.Render
---@field private data render.md.bullet.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    local marker = self.node:child_at(0)
    if not marker then
        return false
    end
    self.data = {
        marker = marker,
        -- https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
        spaces = Str.spaces('start', marker.text),
        checkbox = self.context:get_checkbox(self.node.start_row),
    }
    return true
end

function Render:render()
    if self:has_checkbox() then
        -- Hide the list marker for checkboxes rather than replacing with a bullet point
        self:hide_marker()
        if self.data.checkbox then
            local scope_highlight = self.data.checkbox.scope_highlight
            self:highlight_scope('check_scope', scope_highlight)
        end
    else
        local info = self.config.bullet
        if self.context:skip(info) then
            return
        end

        local ordered_types = { 'list_marker_dot', 'list_marker_parenthesis' }
        local ordered = vim.tbl_contains(ordered_types, self.data.marker.type)
        local icons = ordered and info.ordered_icons or info.icons

        local level, root = self.node:level_in_section('list')
        ---@type render.md.bullet.Context
        local ctx = {
            level = level,
            index = self.node:sibling_count('list_item'),
            value = self.data.marker.text,
        }

        local icon = self:get_string(icons, ctx)
        local highlight = self:get_string(info.highlight, ctx)
        local scope_highlight = self:get_string(info.scope_highlight, ctx)
        local left_pad = self:get_integer(info.left_pad, ctx)
        local right_pad = self:get_integer(info.right_pad, ctx)
        self:icon(icon, highlight)
        self:padding(root, left_pad, right_pad)
        self:highlight_scope(true, scope_highlight)
    end
end

---@private
---@return boolean
function Render:has_checkbox()
    if self.context:skip(self.config.checkbox) then
        return false
    end
    return self.data.checkbox ~= nil
        or self.data.marker:sibling('task_list_marker_unchecked') ~= nil
        or self.data.marker:sibling('task_list_marker_checked') ~= nil
end

---@private
function Render:hide_marker()
    local offset = { 0, self.data.spaces, 0, 0 }
    self.marks:over('check_icon', self.data.marker, { conceal = '' }, offset)
end

---@private
---@param element render.md.mark.Element
---@param highlight string?
function Render:highlight_scope(element, highlight)
    self:scope(element, self.node:child('paragraph'), highlight)
end

---@private
---@param values render.md.bullet.String
---@param ctx render.md.bullet.Context
---@return string?
function Render:get_string(values, ctx)
    if type(values) == 'function' then
        return values(ctx)
    elseif type(values) == 'string' then
        return values
    else
        local value = List.cycle(values, ctx.level)
        if type(value) == 'table' then
            return List.clamp(value, ctx.index)
        else
            return value
        end
    end
end

---@private
---@param value render.md.bullet.Integer
---@param ctx render.md.bullet.Context
---@return integer
function Render:get_integer(value, ctx)
    if type(value) == 'function' then
        return value(ctx)
    else
        return value
    end
end

---@private
---@param icon string?
---@param highlight string?
function Render:icon(icon, highlight)
    if not icon or not highlight then
        return
    end
    local text = Str.pad(self.data.spaces) .. icon
    local overflow = Str.width(text) > Str.width(self.data.marker.text)
    self.marks:over('bullet', self.data.marker, {
        virt_text = { { text, highlight } },
        virt_text_pos = overflow and 'inline' or 'overlay',
        conceal = overflow and '' or nil,
    })
end

---@private
---@param root? render.md.Node
---@param left_pad integer
---@param right_pad integer
function Render:padding(root, left_pad, right_pad)
    if left_pad <= 0 and right_pad <= 0 then
        return
    end
    local start_row, end_row = self.node.start_row, self:end_row(root)
    local left_line = self.config:line():pad(left_pad):get()
    local right_line = self.config:line():pad(right_pad):get()
    for row = start_row, end_row - 1 do
        local left = root and root.start_col or self.node.start_col
        local right = row == start_row and self.data.marker.end_col - 1 or left
        if #left_line > 0 then
            self.marks:add(false, row, left, {
                priority = 0,
                virt_text = left_line,
                virt_text_pos = 'inline',
            })
        end
        if #right_line > 0 then
            self.marks:add(false, row, right, {
                priority = 0,
                virt_text = right_line,
                virt_text_pos = 'inline',
            })
        end
    end
end

---@private
---@param root? render.md.Node
---@return integer
function Render:end_row(root)
    local sub_list = self.node:child('list')
    if sub_list then
        return sub_list.start_row
    elseif not root then
        return self.node.end_row
    else
        -- on the last item of the root list ignore the last line if empty
        local row = self.node.end_row
        local _, line = root:line('last', 0)
        local ignore_last = root.end_row == row and Str.width(line) == 0
        local offset = ignore_last and 1 or 0
        return row - offset
    end
end

return Render
