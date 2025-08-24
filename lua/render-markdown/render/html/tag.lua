local Base = require('render-markdown.render.base')

---@class render.md.render.html.Tag: render.md.Render
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
    local start_tag = self.node:child('start_tag')
    local end_tag = self.node:child('end_tag')
    local name = start_tag and start_tag:child('tag_name')
    local config = name and self.config.tag[name.text]
    if not config then
        return
    end
    self.marks:over(self.config, true, start_tag, { conceal = '' })
    self.marks:over(self.config, true, end_tag, { conceal = '' })
    self.marks:start(self.config, false, self.node, {
        virt_text = { { config.icon, config.highlight } },
        virt_text_pos = 'inline',
    })
end

return Render
