local Base = require('render-markdown.render.base')

---@class render.md.render.InlineHighlight: render.md.Render
---@field private info render.md.inline.highlight.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.inline_highlight
    if self.context:skip(self.info) then
        return false
    end
    return true
end

function Render:render()
    for _, range in ipairs(self.node:find('==[^=]+==')) do
        -- Hide first 2 equal signs
        self:hide_equals(range[1], range[2])
        -- Highlight contents
        self.marks:add(false, range[1], range[2], {
            end_row = range[3],
            end_col = range[4],
            hl_group = self.info.highlight,
        })
        -- Hide last 2 equal signs
        self:hide_equals(range[3], range[4] - 2)
    end
end

---@private
---@param row integer
---@param col integer
function Render:hide_equals(row, col)
    self.marks:add(true, row, col, {
        end_col = col + 2,
        conceal = '',
    })
end

return Render
