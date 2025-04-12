local Base = require('render-markdown.render.base')
local Converter = require('render-markdown.lib.converter')
local Str = require('render-markdown.lib.str')

---@class render.md.render.Shortcut: render.md.Render
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    return true
end

function Render:render()
    local callout = self.config:get_callout(self.node)
    if callout ~= nil then
        self:callout(callout)
        return
    end

    local checkbox = self.config:get_checkbox(self.node)
    if checkbox ~= nil then
        self:checkbox(checkbox)
        return
    end

    local line = self.node:line('first', 0)
    if
        line ~= nil
        and line:find('[' .. self.node.text .. ']', 1, true) ~= nil
    then
        self:wiki_link()
        return
    end

    local _, _, text = self.node.text:find('^%[%^(.+)%]$')
    if text ~= nil then
        self:footnote(text)
        return
    end
end

---@private
---@param callout render.md.callout.Config
function Render:callout(callout)
    if self.context:skip(self.config.quote) then
        return
    end

    local text, conceal = self:callout_title(callout)
    self.marks:over('callout', self.node, {
        virt_text = { { text, callout.highlight } },
        virt_text_pos = 'overlay',
        conceal = conceal and '' or nil,
    })
    self.context:add_callout(self.node.start_row, callout)
end

---@private
---@param callout render.md.callout.Config
---@return string, boolean
function Render:callout_title(callout)
    ---Support for overriding title: https://help.obsidian.md/Editing+and+formatting/Callouts#Change+the+title
    local content = self.node:parent('inline')
    if content ~= nil then
        local line = Str.split(content.text, '\n', true)[1]
        if
            #line > #callout.raw
            and vim.startswith(line:lower(), callout.raw:lower())
        then
            local icon = Str.split(callout.rendered, ' ', true)[1]
            local title = vim.trim(line:sub(#callout.raw + 1))
            return icon .. ' ' .. title, true
        end
    end
    return callout.rendered, false
end

---@private
---@param checkbox render.md.checkbox.custom.Config
function Render:checkbox(checkbox)
    local config = self.config.checkbox
    if self.context:skip(config) or self.node:after() ~= ' ' then
        return
    end
    local added = self:check_icon(checkbox.rendered, checkbox.highlight)
    if added then
        self.context:add_checkbox(self.node.start_row, checkbox)
    end
end

---@private
function Render:wiki_link()
    local link = self.config.link
    if self.context:skip(link) then
        return
    end

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

    -- Hide opening & closing outer brackets
    self:hide(ctx.start_col, 1)
    self:hide(ctx.end_col - 1, 1)

    local wiki = link.wiki
    local icon, highlight =
        self:dest(wiki.icon, wiki.highlight, ctx.destination)
    local body = wiki.body(ctx)
    if body == nil then
        -- Add icon
        self.marks:start('link', self.node, {
            virt_text = { { icon, highlight } },
            virt_text_pos = 'inline',
        })
        -- Hide destination if there is an alias
        if #sections > 1 then
            self:hide(ctx.start_col + 2, #ctx.destination + 1)
        end
    else
        local line = {}
        if type(body) == 'string' then
            line[#line + 1] = { icon .. body, highlight }
        else
            line[#line + 1] = { icon .. body[1], body[2] }
        end
        -- Inline icon & body, hide original text
        self.marks:over('link', self.node, {
            virt_text = line,
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
    local link = self.config.link
    if self.context:skip(link) then
        return
    end
    local footnote = link.footnote
    if not footnote.enabled then
        return
    end
    local body = footnote.prefix .. text .. footnote.suffix
    local value = not footnote.superscript and body
        or Converter.superscript(body)
    if value == nil then
        return
    end
    self.marks:over('link', self.node, {
        virt_text = { { value, link.highlight } },
        virt_text_pos = 'inline',
        conceal = '',
    })
end

return Render
