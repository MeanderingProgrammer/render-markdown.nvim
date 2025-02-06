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
        self:icon(level)
        self:padding(root)
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
    self.marks:add_over('check_icon', self.data.marker, {
        conceal = '',
    }, { 0, self.data.spaces, 0, 0 })
end

---@private
function Render:highlight_scope()
    if self.data.checkbox == nil then
        return
    end
    self:checkbox_scope(self.node:child('paragraph'), self.data.checkbox.scope_highlight)
end

---@private
---@param level integer
function Render:icon(level)
    local node = self.data.marker
    local index = self.node:sibling_count('list_item')
    local icons = self.data.ordered and self.bullet.ordered_icons or self.bullet.icons
    local icon = nil
    if type(icons) == 'function' then
        icon = icons({ level = level, index = index, value = node.text })
    else
        icon = List.cycle(icons, level)
        if type(icon) == 'table' then
            icon = List.clamp(icon, index)
        end
    end
    if icon == nil then
        return
    end
    local text = Str.pad(self.data.spaces) .. icon
    local position, conceal = 'overlay', nil
    if Str.width(text) > Str.width(node.text) then
        position, conceal = 'inline', ''
    end
    self.marks:add_over('bullet', node, {
        virt_text = { { text, self.bullet.highlight } },
        virt_text_pos = position,
        conceal = conceal,
    })
end

---@private
---@param root? render.md.Node
function Render:padding(root)
    if self.bullet.left_pad <= 0 and self.bullet.right_pad <= 0 then
        return
    end
    local left_col = root ~= nil and root.start_col or self.node.start_col
    for row = self.node.start_row, self:end_row(root) - 1 do
        local right_col = row == self.node.start_row and self.data.marker.end_col - 1 or left_col
        self:padding_mark(row, left_col, self.bullet.left_pad)
        self:padding_mark(row, right_col, self.bullet.right_pad)
    end
end

---@private
---@param root? render.md.Node
---@return integer
function Render:end_row(root)
    local next_list = self.node:child('list')
    if next_list ~= nil then
        return next_list.start_row
    end
    local end_row = self.node.end_row
    -- On the last item of the root list ignore the last line if it is empty
    if root ~= nil and root.end_row == end_row then
        if Str.width(self.node:line('last', 0)) == 0 then
            return end_row - 1
        end
    end
    return end_row
end

---@private
---@param row integer
---@param col integer
---@param amount integer
function Render:padding_mark(row, col, amount)
    if amount > 0 then
        self.marks:add(false, row, col, {
            priority = 0,
            virt_text = { self:padding_text(amount) },
            virt_text_pos = 'inline',
        })
    end
end

return Render
