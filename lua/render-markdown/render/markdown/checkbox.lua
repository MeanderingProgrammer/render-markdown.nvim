local Base = require('render-markdown.render.base')
local Bullet = require('render-markdown.render.markdown.bullet')
local str = require('render-markdown.lib.str')

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
    if not self.config.enabled then
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
    self:checkbox()
    self:scope()
end

---@private
function Render:marker()
    if self.config.bullet then
        Bullet:execute(self.context, self.marks, self.node)
    else
        -- https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
        local node = self.data.marker
        self.marks:over(self.config, 'check_icon', node, {
            conceal = '',
        }, { 0, str.spaces('start', node.text), 0, 0 })
    end
end

---@private
function Render:checkbox()
    -- add 1 to end to account for space after checkbox
    local node = self.data.checkbox
    local row = node.start_row
    local start_col = node.start_col
    local end_col = node.end_col + 1
    local width = self.context:width(node) + 1

    local line = self:line()
        :pad(self.config.left_pad)
        :text(self.data.icon, self.data.highlight)
        :pad(self.config.right_pad)

    local overlay = line:sub(1, width)
    if not overlay:empty() then
        self.marks:add(self.config, 'check_icon', row, start_col, {
            virt_text = overlay:get(),
            virt_text_pos = 'overlay',
        })
    end

    local inline = line:sub(width + 1, line:width())
    if not inline:empty() then
        self.marks:add(self.config, 'check_icon', row, end_col, {
            virt_text = inline:get(),
            virt_text_pos = 'inline',
        })
    end

    local space = width - overlay:width()
    if space > 0 then
        self.marks:add(self.config, 'check_icon', row, end_col - space, {
            end_col = end_col,
            conceal = '',
        })
    end
end

---@private
function Render:scope()
    local highlight = self.data.scope_highlight
    if not highlight then
        return
    end
    self.marks:over(self.config, 'check_scope', self.node:scope(), {
        priority = self.config.scope_priority,
        hl_group = highlight,
    })
end

return Render
