local Base = require('render-markdown.render.base')
local colors = require('render-markdown.core.colors')
local str = require('render-markdown.lib.str')

---@class render.md.render.inline.Code: render.md.Render
---@field private config render.md.code.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.code
    if not self.config.inline then
        return false
    end
    return self.config.enabled
end

---@protected
function Render:run()
    local highlight = self.config.highlight_inline
    self.marks:over(self.config, 'code_background', self.node, {
        priority = self.config.priority,
        hl_group = highlight,
    })
    self:padding(highlight, true)
    self:padding(highlight, false)
    self:hide_spaces()
end

---@private
---@param highlight string
---@param left boolean
function Render:padding(highlight, left)
    local line = self:line()
    if left then
        line:text(
            self.config.inline_left,
            self.config.highlight_inline_left or colors.bg_as_fg(highlight)
        )
        line:pad(self.config.inline_pad, highlight)
    else
        line:pad(self.config.inline_pad, highlight)
        line:text(
            self.config.inline_right,
            self.config.highlight_inline_right or colors.bg_as_fg(highlight)
        )
    end
    if not line:empty() then
        local row = left and self.node.start_row or self.node.end_row
        local col = left and self.node.start_col or self.node.end_col
        self.marks:add(self.config, true, row, col, {
            priority = 0,
            virt_text = line:get(),
            virt_text_pos = 'inline',
        })
    end
end

---@private
function Render:hide_spaces()
    local delimiters = {} ---@type render.md.Node[]
    self.node:for_each_child(function(child)
        if child.type == 'code_span_delimiter' then
            delimiters[#delimiters + 1] = child
        end
    end)
    if #delimiters ~= 2 then
        return
    end
    local open, close = unpack(delimiters)
    local opens = str.width(open.text)
    local closes = str.width(close.text)
    if opens == 0 or closes == 0 or opens ~= closes then
        return
    end
    local body = self.node.text:sub(opens + 1, -(closes + 1))
    local leading = str.spaces('start', body)
    local trailing = str.spaces('end', body)
    if leading == 0 or trailing == 0 or not body:match('%S') then
        return
    end
    self:hide(open.end_row, open.end_col, 1)
    self:hide(close.start_row, close.start_col - 1, 1)
end

---@private
---@param row integer
---@param col integer
---@param length integer
function Render:hide(row, col, length)
    self.marks:add(self.config, true, row, col, {
        end_col = col + length,
        conceal = '',
    })
end

return Render
