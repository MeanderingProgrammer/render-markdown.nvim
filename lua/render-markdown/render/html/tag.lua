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

    local icon, highlight = config.icon, config.highlight
    if icon and highlight then
        self.marks:start(self.config, false, self.node, {
            virt_text = { { icon, highlight } },
            virt_text_pos = 'inline',
        })
    end

    local scope_highlight = config.scope_highlight
    local start_row = start_tag and start_tag.end_row or self.node.start_row
    local start_col = start_tag and start_tag.end_col or self.node.start_col
    local end_row = end_tag and end_tag.start_row or self.node.end_row
    local end_col = end_tag and end_tag.start_col or self.node.end_col
    if scope_highlight then
        self.marks:add(self.config, true, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            hl_group = scope_highlight,
        })
    end
end

return Render
