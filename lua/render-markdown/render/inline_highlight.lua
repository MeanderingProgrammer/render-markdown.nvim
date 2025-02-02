local Base = require('render-markdown.render.base')
local Str = require('render-markdown.lib.str')

---@class render.md.render.InlineHighlight: render.md.Renderer
---@field private highlight render.md.InlineHighlight
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.highlight = self.config.inline_highlight
    if self.context:skip(self.highlight) then
        return false
    end
    return true
end

function Render:render()
    for _, range in ipairs(Str.find_all(self.node.text, '==[^=]+==')) do
        local start_row, start_col = self:row_col(range[1], 1)
        local end_row, end_col = self:row_col(range[2], 0)
        -- Hide first 2 equal signs
        self:hide_equals(start_row, start_col)
        -- Highlight contents
        self.marks:add(false, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            hl_group = self.highlight.highlight,
        })
        -- Hide last 2 equal signs
        self:hide_equals(end_row, end_col - 2)
    end
end

---@private
---@param index integer
---@param offset integer
---@return integer, integer
function Render:row_col(index, offset)
    local lines = Str.split(self.node.text:sub(1, index), '\n')
    local row = self.node.start_row + #lines - 1
    local col = #lines[#lines] - offset
    if row == self.node.start_row then
        col = col + self.node.start_col
    end
    return row, col
end

---@private
---@param row integer
---@param col integer
function Render:hide_equals(row, col)
    self.marks:add(true, row, col, {
        end_row = row,
        end_col = col + 2,
        conceal = '',
    })
end

return Render
