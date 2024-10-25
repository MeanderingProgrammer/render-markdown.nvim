local Base = require('render-markdown.render.base')
local List = require('render-markdown.lib.list')
local Str = require('render-markdown.lib.str')

---@class render.md.data.ListMarker
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

    self.data = {
        -- List markers from tree-sitter should have leading spaces removed, however there are edge
        -- cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
        -- As a result we account for leading spaces here, can remove if this gets fixed upstream
        spaces = Str.spaces('start', self.node.text),
        checkbox = self.context:get_checkbox(self.node),
    }

    return true
end

function Render:render()
    if self:sibling_checkbox() then
        -- Hide the list marker for checkboxes rather than replacing with a bullet point
        self:hide_marker()
        self:highlight_scope()
    else
        if not self.bullet.enabled then
            return
        end
        local level, root_list = self.node:level_in_section('list')
        self:icon(level)
        self:padding(root_list)
    end
end

---@private
---@return boolean
function Render:sibling_checkbox()
    if not self.config.checkbox.enabled then
        return false
    end
    if self.data.checkbox ~= nil then
        return true
    end
    if self.node:sibling('task_list_marker_unchecked') ~= nil then
        return true
    end
    if self.node:sibling('task_list_marker_checked') ~= nil then
        return true
    end
    return false
end

---@private
function Render:hide_marker()
    self.marks:add('check_icon', self.node.start_row, self.node.start_col + self.data.spaces, {
        end_row = self.node.end_row,
        end_col = self.node.end_col,
        conceal = '',
    })
end

---@private
function Render:highlight_scope()
    if self.data.checkbox == nil then
        return
    end
    self:checkbox_scope(self.data.checkbox.scope_highlight)
end

---@private
---@param level integer
function Render:icon(level)
    local icon = List.cycle(self.bullet.icons, level)
    if type(icon) == 'table' then
        local item = self.node:parent('list_item')
        if item == nil then
            return
        end
        icon = List.clamp(icon, item:sibling_count('list_item'))
    end
    if icon == nil then
        return
    end
    local text = Str.pad(self.data.spaces) .. icon
    local position, conceal = 'overlay', nil
    if Str.width(text) > Str.width(self.node.text) then
        position, conceal = 'inline', ''
    end
    self.marks:add('bullet', self.node.start_row, self.node.start_col, {
        end_row = self.node.end_row,
        end_col = self.node.end_col,
        virt_text = { { text, self.bullet.highlight } },
        virt_text_pos = position,
        conceal = conceal,
    })
end

---@private
---@param root_list? render.md.Node
function Render:padding(root_list)
    if self.bullet.left_pad <= 0 and self.bullet.right_pad <= 0 then
        return
    end
    local list_item = self.node:parent('list_item')
    if list_item == nil then
        return
    end
    local left_col = root_list ~= nil and root_list.start_col or list_item.start_col

    local next_list = list_item:child('list')
    local end_row = next_list ~= nil and next_list.start_row or list_item.end_row

    for row = list_item.start_row, end_row - 1 do
        local right_col = row == list_item.start_row and self.node.end_col - 1 or left_col
        self:padding_mark(row, left_col, self.bullet.left_pad)
        self:padding_mark(row, right_col, self.bullet.right_pad)
    end
end

---@private
---@param row integer
---@param col integer
---@param amount integer
function Render:padding_mark(row, col, amount)
    if amount > 0 then
        self.marks:add(false, row, col, {
            priority = 0,
            virt_text = { { Str.pad(amount), self.config.padding.highlight } },
            virt_text_pos = 'inline',
        })
    end
end

return Render
