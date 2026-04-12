local Base = require('render-markdown.render.base')
local colors = require('render-markdown.core.colors')

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
    self:conceal_padding()
    self:padding(highlight, true)
    self:padding(highlight, false)
end

--- Per CommonMark spec, when a code span uses multiple backtick delimiters,
--- a single leading and trailing space is stripped from the content (provided
--- the content is not entirely whitespace). Conceal those spaces so the
--- rendered output matches what CommonMark produces.
---@private
function Render:conceal_padding()
    local delimiters = {}
    self.node:for_each_child(function(child)
        if child.type == 'code_span_delimiter' then
            delimiters[#delimiters + 1] = child
        end
    end)
    if #delimiters < 2 then
        return
    end
    -- Only applies when delimiter is more than one backtick
    local open = delimiters[1]
    local close = delimiters[#delimiters]
    if (open.end_col - open.start_col) <= 1 then
        return
    end
    -- Extract the text between delimiters
    local content = self.node.text:sub(open.end_col - self.node.start_col + 1, close.start_col - self.node.start_col)
    -- Content must start and end with a space and not be entirely whitespace
    if not (content:sub(1, 1) == ' ' and content:sub(-1) == ' ' and content:match('%S')) then
        return
    end
    -- Conceal the leading space (right after opening delimiter)
    self.marks:add(self.config, true, open.end_row, open.end_col, {
        end_row = open.end_row,
        end_col = open.end_col + 1,
        conceal = '',
    })
    -- Conceal the trailing space (right before closing delimiter)
    self.marks:add(self.config, true, close.start_row, close.start_col - 1, {
        end_row = close.start_row,
        end_col = close.start_col,
        conceal = '',
    })
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

return Render
