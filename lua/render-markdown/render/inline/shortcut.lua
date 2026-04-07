local Base = require('render-markdown.render.base')
local Footnote = require('render-markdown.render.common.footnote')
local Wiki = require('render-markdown.render.common.wiki')

---@class render.md.render.inline.Shortcut: render.md.Render
---@field private config render.md.link.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    local callout = self.context.config.resolved:callout(self.node)
    if callout then
        self.context.callout:set(self.node, callout)
        return false
    end
    local checkbox = self.context.config.resolved:checkbox(self.node)
    if checkbox then
        if self.node:after() == ' ' then
            self.context.checkbox:set(self.node, checkbox)
        end
        return false
    end
    self.config = self.context.config.link
    return self.config.enabled
end

---@protected
function Render:run()
    local _, line = self.node:line('first', 0)
    if line and line:find('[' .. self.node.text .. ']', 1, true) then
        Wiki:execute(self.context, self.marks, self.node)
    else
        Footnote:execute(self.context, self.marks, self.node)
    end
end

return Render
