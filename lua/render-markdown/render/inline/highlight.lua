local Base = require('render-markdown.render.base')

---@class render.md.render.inline.Highlight: render.md.Render
---@field private config render.md.inline.highlight.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.inline_highlight
    if not self.config.enabled then
        return false
    end
    return true
end

---@protected
function Render:run()
    for _, range in ipairs(self.node:find('==[^=]+==')) do
        -- hide first 2 equal signs
        self:hide(range[1], range[2], range[2] + 2)
        -- highlight contents
        self.marks:add(self.config, false, range[1], range[2], {
            end_row = range[3],
            end_col = range[4],
            hl_group = self.config.highlight,
        })
        -- hide last 2 equal signs
        self:hide(range[3], range[4] - 2, range[4])
    end
end

---@private
---@param row integer
---@param start_col integer
---@param end_col integer
function Render:hide(row, start_col, end_col)
    self.marks:add(self.config, true, row, start_col, {
        end_col = end_col,
        conceal = '',
    })
end

return Render
