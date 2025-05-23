local Base = require('render-markdown.render.base')
local Converter = require('render-markdown.lib.converter')
local Str = require('render-markdown.lib.str')

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
    if self.context:skip(self.config) then
        return false
    end
    return true
end

---@protected
function Render:run()
    local _, line = self.node:line('first', 0)
    local wiki_pattern = '[' .. self.node.text .. ']'
    if line and line:find(wiki_pattern, 1, true) then
        self:wiki_link()
        return
    end
    local _, _, text = self.node.text:find('^%[%^(.+)%]$')
    if text then
        self:footnote(text)
        return
    end
end

---@private
function Render:wiki_link()
    local config = self.config.wiki
    local sections = Str.split(self.node.text:sub(2, -2), '|', true)
    ---@type render.md.link.Context
    local ctx = {
        buf = self.context.buf,
        row = self.node.start_row,
        start_col = self.node.start_col - 1,
        end_col = self.node.end_col + 1,
        destination = sections[1],
        alias = sections[2],
    }
    -- hide opening & closing outer brackets
    self:hide(ctx.start_col, 1)
    self:hide(ctx.end_col - 1, 1)
    ---@type render.md.mark.Text
    local icon = { config.icon, config.highlight }
    self.context.config:set_link_text(ctx.destination, icon)
    local body = config.body(ctx)
    if not body then
        -- add icon
        self.marks:start('link', self.node, {
            hl_mode = 'combine',
            virt_text = { icon },
            virt_text_pos = 'inline',
        })
        -- hide destination if there is an alias
        if #sections > 1 then
            self:hide(ctx.start_col + 2, #ctx.destination + 1)
        end
    else
        if type(body) == 'string' then
            icon[1] = icon[1] .. body
        else
            icon[1] = icon[1] .. body[1]
            icon[2] = body[2]
        end
        -- inline icon & body, hide original text
        self.marks:over('link', self.node, {
            hl_mode = 'combine',
            virt_text = { icon },
            virt_text_pos = 'inline',
            conceal = '',
        }, { 0, 1, 0, -1 })
    end
end

---@private
---@param col integer
---@param length integer
function Render:hide(col, length)
    self.marks:add(true, self.node.start_row, col, {
        end_col = col + length,
        conceal = '',
    })
end

---@private
---@param text string
function Render:footnote(text)
    local config = self.config.footnote
    if not config.enabled then
        return
    end
    local body = config.prefix .. text .. config.suffix
    local value = body ---@type string?
    if config.superscript then
        value = Converter.superscript(body)
    end
    if not value then
        return
    end
    self.marks:over('link', self.node, {
        virt_text = { { value, self.config.highlight } },
        virt_text_pos = 'inline',
        conceal = '',
    })
end

return Render
