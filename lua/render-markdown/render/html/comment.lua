local Base = require('render-markdown.render.base')

---@class render.md.render.html.Comment: render.md.Render
---@field private config render.md.html.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.html
    return true
end

---@protected
function Render:run()
    local config = self.config.comment
    if not config.conceal then
        return
    end
    self.marks:over(self.config, true, self.node, { conceal = '' })
    if config.text then
        self.marks:start(self.config, true, self.node, {
            virt_text = { { config.text, config.highlight } },
            virt_text_pos = 'inline',
        })
    end
end

return Render
