local Base = require('render-markdown.render.base')

---@class render.md.render.Document: render.md.Render
---@field private info render.md.document.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.info = self.config.document
    if self.context:skip(self.info) then
        return false
    end
    return true
end

function Render:render()
    for _, pattern in ipairs(self.info.conceal.char_patterns) do
        for _, range in ipairs(self.node:find(pattern)) do
            self.marks:add(true, range[1], range[2], {
                end_row = range[3],
                end_col = range[4],
                conceal = '',
            })
        end
    end
    for _, pattern in ipairs(self.info.conceal.line_patterns) do
        for _, range in ipairs(self.node:find(pattern)) do
            self.marks:add(true, range[1], 0, {
                end_row = range[3],
                end_col = 0,
                conceal_lines = '',
            })
        end
    end
end

return Render
