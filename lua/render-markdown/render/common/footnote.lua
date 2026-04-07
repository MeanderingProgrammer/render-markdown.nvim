local Base = require('render-markdown.render.base')
local converter = require('render-markdown.lib.converter')

---@class render.md.render.common.Footnote: render.md.Render
---@field private config render.md.link.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.link
    return self.config.enabled
end

---@protected
function Render:run()
    local config = self.config.footnote
    if not config.enabled then
        return
    end
    local _, _, text = self.node.text:find('^%[%^(.+)%]$')
    if not text then
        return
    end
    local body = config.body({ text = text })
    body = body and config.prefix .. body .. config.suffix
    if config.superscript then
        body = body and converter.superscript(body)
    end
    if not body then
        return
    end
    self.marks:over(self.config, 'link', self.node, {
        virt_text = { { config.icon .. body, self.config.highlight } },
        virt_text_pos = 'inline',
        conceal = '',
    })
end

return Render
