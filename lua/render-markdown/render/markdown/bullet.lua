local Base = require('render-markdown.render.base')
local list = require('render-markdown.lib.list')
local str = require('render-markdown.lib.str')

---@class render.md.bullet.Data
---@field marker render.md.Node
---@field root? render.md.Node
---@field icon? string
---@field highlight? string
---@field scope_highlight? string
---@field left_pad integer
---@field right_pad integer

---@class render.md.render.Bullet: render.md.Render
---@field private config render.md.bullet.Config
---@field private data render.md.bullet.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.bullet
    if not self.config.enabled then
        return false
    end
    local marker = self.node:child_at(0)
    if not marker then
        return false
    end
    local level, root = self.node:level_in('list', 'section')
    ---@type render.md.bullet.Context
    local ctx = {
        level = level,
        index = self.node:sibling_count('list_item'),
        value = marker.text,
    }
    local ordered_types = { 'list_marker_dot', 'list_marker_parenthesis' }
    local ordered = vim.tbl_contains(ordered_types, marker.type)
    local icons = ordered and self.config.ordered_icons or self.config.icons
    self.data = {
        marker = marker,
        root = root,
        icon = Render.get_string(icons, ctx),
        highlight = Render.get_string(self.config.highlight, ctx),
        scope_highlight = Render.get_string(self.config.scope_highlight, ctx),
        left_pad = Render.get_integer(self.config.left_pad, ctx),
        right_pad = Render.get_integer(self.config.right_pad, ctx),
    }
    return true
end

---@private
---@param values render.md.bullet.String
---@param ctx render.md.bullet.Context
---@return string?
function Render.get_string(values, ctx)
    if type(values) == 'function' then
        return values(ctx)
    else
        local value = list.cycle(values, ctx.level)
        return list.clamp(value, ctx.index)
    end
end

---@private
---@param value render.md.bullet.Integer
---@param ctx render.md.bullet.Context
---@return integer
function Render.get_integer(value, ctx)
    if type(value) == 'function' then
        return value(ctx)
    else
        return value
    end
end

---@protected
function Render:run()
    self:marker()
    self:padding()
    self:scope()
end

---@private
function Render:marker()
    local icon = self.data.icon
    local highlight = self.data.highlight
    if not icon or not highlight then
        return
    end
    -- https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
    local node = self.data.marker
    local text = str.pad(str.spaces('start', node.text)) .. icon
    local overflow = str.width(text) > str.width(node.text)
    self.marks:over(self.config, 'bullet', node, {
        virt_text = { { text, highlight } },
        virt_text_pos = overflow and 'inline' or 'overlay',
        conceal = overflow and '' or nil,
    })
end

---@private
function Render:padding()
    local left_line = self:line():pad(self.data.left_pad):get()
    local right_line = self:line():pad(self.data.right_pad):get()
    if #left_line == 0 and #right_line == 0 then
        return
    end
    local root = self.data.root
    local start_row, end_row = self.node.start_row, self:end_row()
    for row = start_row, end_row - 1 do
        local left = root and root.start_col or self.node.start_col
        local right = row == start_row and self.data.marker.end_col - 1 or left
        if #left_line > 0 then
            self.marks:add(self.config, false, row, left, {
                priority = 100,
                virt_text = left_line,
                virt_text_pos = 'inline',
            })
        end
        if #right_line > 0 then
            self.marks:add(self.config, false, row, right, {
                priority = 100,
                virt_text = right_line,
                virt_text_pos = 'inline',
            })
        end
    end
end

---@private
---@return integer
function Render:end_row()
    local sub_list = self.node:child('list')
    if sub_list then
        return sub_list.start_row
    end
    local root = self.data.root
    if not root then
        return self.node.end_row
    end
    -- on the last item of the root list ignore the last line if empty
    local row = self.node.end_row
    local _, line = root:line('last', 0)
    local ignore_last = root.end_row == row and str.width(line) == 0
    local offset = ignore_last and 1 or 0
    return row - offset
end

---@private
function Render:scope()
    local highlight = self.data.scope_highlight
    if not highlight then
        return
    end
    self.marks:over(self.config, true, self.node:scope(), {
        priority = self.config.scope_priority,
        hl_group = highlight,
    })
end

return Render
