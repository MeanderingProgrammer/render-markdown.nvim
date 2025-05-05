local Base = require('render-markdown.render.base')

---@class render.md.render.inline.Highlight: render.md.Render
---@field private config render.md.inline.highlight.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.inline_highlight
    if self.context:skip(self.config) then
        return false
    end
    return true
end

---@protected
function Render:run()
    for _, range in ipairs(self.node:find('==[^=]+==')) do
        -- hide first 2 equal signs
        self:hide_equals(range[1], range[2])
        -- highlight contents
        self.marks:add(false, range[1], range[2], {
            end_row = range[3],
            end_col = range[4],
            hl_group = self.config.highlight,
        })
        -- hide last 2 equal signs
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
