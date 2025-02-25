local Base = require('render-markdown.render.base')
local List = require('render-markdown.lib.list')
local Str = require('render-markdown.lib.str')

---@class render.md.data.ListMarker
---@field marker render.md.Node
---@field ordered boolean
---@field spaces integer
---@field checkbox? render.md.CustomCheckbox

---@class render.md.render.ListMarker: render.md.Renderer
---@field private bullet render.md.Bullet
---@field private data render.md.data.ListMarker
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.bullet = self.config.bullet

    local marker = self.node:child_at(0)
    if marker == nil then
        return false
    end

    self.data = {
        marker = marker,
        ordered = vim.tbl_contains({ 'list_marker_dot', 'list_marker_parenthesis' }, marker.type),
        -- List markers from tree-sitter should have leading spaces removed, however there are edge
        -- cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
        -- As a result we account for leading spaces here, can remove if this gets fixed upstream
        spaces = Str.spaces('start', marker.text),
        checkbox = self.context:get_checkbox(self.node.start_row),
    }

    return true
end

function Render:render()
    if self:has_checkbox() then
        -- Hide the list marker for checkboxes rather than replacing with a bullet point
        self:hide_marker()
        self:highlight_scope()
    else
        if self.context:skip(self.bullet) then
            return
        end
        local level, root = self.node:level_in_section('list')
        ---@type render.md.BulletContext
        local ctx = {
            level = level,
            index = self.node:sibling_count('list_item'),
            value = self.data.marker.text,
        }
        local icon = self:get_icon(ctx)
        local left_pad = self:get_padding(ctx, self.bullet.left_pad)
        local right_pad = self:get_padding(ctx, self.bullet.right_pad)
        self:add_icon(icon)
        self:add_padding(left_pad, right_pad, root)
    end
end

---@private
---@return boolean
function Render:has_checkbox()
    if self.context:skip(self.config.checkbox) then
        return false
    end
    if self.data.checkbox ~= nil then
        return true
    end
    if self.data.marker:sibling('task_list_marker_unchecked') ~= nil then
        return true
    end
    if self.data.marker:sibling('task_list_marker_checked') ~= nil then
        return true
    end
    return false
end

---@private
function Render:hide_marker()
    self.marks:add_over('check_icon', self.data.marker, { conceal = '' }, { 0, self.data.spaces, 0, 0 })
end

---@private
function Render:highlight_scope()
    if self.data.checkbox == nil then
        return
    end
    self:checkbox_scope(self.node:child('paragraph'), self.data.checkbox.scope_highlight)
end

---@private
---@param ctx render.md.BulletContext
---@return string?
function Render:get_icon(ctx)
    local icons = self.data.ordered and self.bullet.ordered_icons or self.bullet.icons
    if type(icons) == 'function' then
        return icons(ctx)
    else
        local icon = List.cycle(icons, ctx.level)
        if type(icon) == 'table' then
            return List.clamp(icon, ctx.index)
        else
            return icon
        end
    end
end

---@private
---@param ctx render.md.BulletContext
---@param pad render.md.bullet.Padding
---@return integer
function Render:get_padding(ctx, pad)
    if type(pad) == 'function' then
        return pad(ctx)
    else
        return pad
    end
end

---@private
---@param icon string?
function Render:add_icon(icon)
    if icon == nil then
        return
    end
    local text = Str.pad(self.data.spaces) .. icon
    local overflow = Str.width(text) > Str.width(self.data.marker.text)
    self.marks:add_over('bullet', self.data.marker, {
        virt_text = { { text, self.bullet.highlight } },
        virt_text_pos = overflow and 'inline' or 'overlay',
        conceal = overflow and '' or nil,
    })
end

---@private
---@param left_pad integer
---@param right_pad integer
---@param root? render.md.Node
function Render:add_padding(left_pad, right_pad, root)
    if left_pad <= 0 and right_pad <= 0 then
        return
    end
    local start_row, end_row = self.node.start_row, self:end_row(root)
    for row = start_row, end_row - 1 do
        local left_col = root ~= nil and root.start_col or self.node.start_col
        local right_col = row == start_row and self.data.marker.end_col - 1 or left_col
        self:side_padding(row, left_col, left_pad)
        self:side_padding(row, right_col, right_pad)
    end
end

---@private
---@param root? render.md.Node
---@return integer
function Render:end_row(root)
    local next_list = self.node:child('list')
    if next_list ~= nil then
        return next_list.start_row
    else
        local row = self.node.end_row
        -- On the last item of the root list ignore the last line if it is empty
        if root ~= nil and root.end_row == row and Str.width(root:line('last', 0)) == 0 then
            return row - 1
        else
            return row
        end
    end
end

---@private
---@param row integer
---@param col integer
---@param amount integer
function Render:side_padding(row, col, amount)
    if amount > 0 then
        self.marks:add(false, row, col, {
            priority = 0,
            virt_text = { self:pad(amount) },
            virt_text_pos = 'inline',
        })
    end
end

return Render
