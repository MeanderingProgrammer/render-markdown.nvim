local Base = require('render-markdown.render.base')
local Converter = require('render-markdown.lib.converter')
local Str = require('render-markdown.lib.str')

---@class render.md.render.Shortcut: render.md.Renderer
---@field private link render.md.Link
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    self.link = self.config.link
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
    if line ~= nil and line:find('[' .. self.node.text .. ']', 1, true) ~= nil then
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
---@param callout render.md.CustomCallout
function Render:callout(callout)
    if self.context:skip(self.config.quote) then
        return
    end

    local text, conceal = self:callout_title(callout)
    self.marks:add_over('callout', self.node, {
        virt_text = { { text, callout.highlight } },
        virt_text_pos = 'overlay',
        conceal = conceal and '' or nil,
    })
    self.context:add_callout(self.node.start_row, callout)
end

---@private
---@param callout render.md.CustomCallout
---@return string, boolean
function Render:callout_title(callout)
    ---Support for overriding title: https://help.obsidian.md/Editing+and+formatting/Callouts#Change+the+title
    local content = self.node:parent('inline')
    if content ~= nil then
        local line = Str.split(content.text, '\n')[1]
        if #line > #callout.raw and vim.startswith(line:lower(), callout.raw:lower()) then
            local icon = Str.split(callout.rendered, ' ')[1]
            local title = vim.trim(line:sub(#callout.raw + 1))
            return icon .. ' ' .. title, true
        end
    end
    return callout.rendered, false
end

---@private
---@param checkbox render.md.CustomCheckbox
function Render:checkbox(checkbox)
    if self.context:skip(self.config.checkbox) then
        return
    end

    local inline = self.config.checkbox.position == 'inline'
    local icon, highlight = checkbox.rendered, checkbox.highlight
    local added = self.marks:add_over('check_icon', self.node, {
        virt_text = { { inline and icon or Str.pad_to(self.node.text, icon) .. icon, highlight } },
        virt_text_pos = 'inline',
        conceal = '',
    })

    if added then
        self.context:add_checkbox(self.node.start_row, checkbox)
    end
end

---@private
function Render:wiki_link()
    if self.context:skip(self.link) then
        return
    end

    local wiki = self.link.wiki
    local start_col, end_col = self.node.start_col, self.node.end_col
    local values = Str.split(self.node.text:sub(2, -2), '|')

    -- Hide opening outer bracket
    self:hide(start_col - 1, start_col)

    -- Add icon
    local text, highlight = self:from_destination(wiki.icon, wiki.highlight, values[1])

    -- Hide destination if there is an alias
    if #values > 1 then
        self:hide(start_col + 1, start_col + 1 + #values[1] + 1)
    elseif self.config.link.wiki.diagnostic_severity then
        local diagnostic = self.context:get_diagnostic(
            self.node,
            self.config.link.wiki.diagnostic_severity,
            self.config.link.wiki.diagnostic_source
        )
        if diagnostic then
            self:hide(start_col + 1, end_col)
            text = text .. diagnostic
        end
    end

    self.marks:add_over('link', self.node, {
        virt_text = { { text, highlight } },
        virt_text_pos = 'inline',
    })

    -- Hide closing outer bracket
    self:hide(end_col, end_col + 1)
end

---@private
---@param start_col integer
---@param end_col integer
function Render:hide(start_col, end_col)
    self.marks:add(true, self.node.start_row, start_col, {
        end_col = end_col,
        conceal = '',
    })
end

---@private
---@param text string
function Render:footnote(text)
    if self.context:skip(self.link) then
        return
    end

    local footnote = self.link.footnote
    if not footnote.superscript then
        return
    end

    local value = Converter.to_superscript(footnote.prefix .. text .. footnote.suffix)
    if value == nil then
        return
    end

    self.marks:add_over('link', self.node, {
        virt_text = { { value, self.link.highlight } },
        virt_text_pos = 'inline',
        conceal = '',
    })
end

return Render
