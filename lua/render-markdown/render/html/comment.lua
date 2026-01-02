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
    local text = Render.get_string(config.text, { text = self.node.text })
    if text then
        self.marks:start(self.config, true, self.node, {
            virt_text = { { text, config.highlight } },
            virt_text_pos = 'inline',
        })
    end
end

---@private
---@param value? render.md.html.comment.String
---@param ctx render.md.html.comment.Context
---@return string?
function Render.get_string(value, ctx)
    if not value then
        return nil
    elseif type(value) == 'function' then
        return value(ctx)
    else
        return value
    end
end

return Render
