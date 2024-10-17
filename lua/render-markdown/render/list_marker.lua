local Base = require('render-markdown.render.base')
local list = require('render-markdown.core.list')
local str = require('render-markdown.core.str')

---@class render.md.data.ListMarker
---@field leading_spaces integer
---@field checkbox? render.md.CustomCheckbox

---@class render.md.render.ListMarker: render.md.Renderer
---@field private bullet render.md.Bullet
---@field private data render.md.data.ListMarker
local Render = setmetatable({}, Base)
Render.__index = Render

---@param marks render.md.Marks
---@param config render.md.buffer.Config
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Render:new(marks, config, context, info)
    return Base.new(self, marks, config, context, info)
end

---@return boolean
function Render:setup()
    self.bullet = self.config.bullet

    self.data = {
        -- List markers from tree-sitter should have leading spaces removed, however there are edge
        -- cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
        -- As a result we account for leading spaces here, can remove if this gets fixed upstream
        leading_spaces = str.spaces('start', self.info.text),
        checkbox = self.context:get_checkbox(self.info),
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
        local level, root_list = self.info:level_in_section('list')
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
    if self.info:sibling('task_list_marker_unchecked') ~= nil then
        return true
    end
    if self.info:sibling('task_list_marker_checked') ~= nil then
        return true
    end
    return false
end

---@private
function Render:hide_marker()
    self.marks:add('check_icon', self.info.start_row, self.info.start_col + self.data.leading_spaces, {
        end_row = self.info.end_row,
        end_col = self.info.end_col,
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
    local icon = list.cycle(self.bullet.icons, level)
    if icon == nil then
        return
    end
    self.marks:add('bullet', self.info.start_row, self.info.start_col, {
        end_row = self.info.end_row,
        end_col = self.info.end_col,
        virt_text = { { str.pad(self.data.leading_spaces) .. icon, self.bullet.highlight } },
        virt_text_pos = 'overlay',
    })
end

---@private
---@param root_list? render.md.NodeInfo
function Render:padding(root_list)
    if self.bullet.left_pad <= 0 and self.bullet.right_pad <= 0 then
        return
    end
    local list_item = self.info:parent('list_item')
    if list_item == nil then
        return
    end
    local left_col = root_list ~= nil and root_list.start_col or list_item.start_col

    local next_list = list_item:child('list')
    local end_row = next_list ~= nil and next_list.start_row or list_item.end_row

    for row = list_item.start_row, end_row - 1 do
        local right_col = row == list_item.start_row and self.info.end_col - 1 or left_col
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
            virt_text = { { str.pad(amount), self.config.padding.highlight } },
            virt_text_pos = 'inline',
        })
    end
end

return Render
