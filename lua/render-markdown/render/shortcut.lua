local Base = require('render-markdown.render.base')
local str = require('render-markdown.core.str')

---@class render.md.render.Shortcut: render.md.Renderer
local Render = setmetatable({}, Base)
Render.__index = Render

---@param marks render.md.Marks
---@param config render.md.buffer.Config
---@param context render.md.Context
---@param info render.md.NodeInfo
---@return render.md.Renderer
function Render:new(marks, config, context, info)
    return Base.new(self, marks, config, context, info)
end

---@return boolean
function Render:setup()
    return true
end

function Render:render()
    local callout = self.config.component.callout[self.info.text:lower()]
    if callout ~= nil then
        self:callout(callout)
        return
    end

    local checkbox = self.config.component.checkbox[self.info.text:lower()]
    if checkbox ~= nil then
        self:checkbox(checkbox)
        return
    end

    local line = self.info:line('first', 0)
    if line ~= nil and line:find('[' .. self.info.text .. ']', 1, true) ~= nil then
        self:wiki_link()
        return
    end
end

---@private
---@param callout render.md.CustomCallout
function Render:callout(callout)
    if not self.config.quote.enabled then
        return
    end

    local text, conceal = self:callout_title(callout)
    local added = self.marks:add('callout', self.info.start_row, self.info.start_col, {
        end_row = self.info.end_row,
        end_col = self.info.end_col,
        virt_text = { { text, callout.highlight } },
        virt_text_pos = 'overlay',
        conceal = conceal and '' or nil,
    })

    if added then
        self.context:add_callout(self.info, callout)
    end
end

---@private
---@param callout render.md.CustomCallout
---@return string, boolean
function Render:callout_title(callout)
    ---Support for overriding title: https://help.obsidian.md/Editing+and+formatting/Callouts#Change+the+title
    local content = self.info:parent('inline')
    if content ~= nil then
        local line = str.split(content.text, '\n')[1]
        if #line > #callout.raw and vim.startswith(line:lower(), callout.raw:lower()) then
            local icon = str.split(callout.rendered, ' ')[1]
            local title = vim.trim(line:sub(#callout.raw + 1))
            return icon .. ' ' .. title, true
        end
    end
    return callout.rendered, false
end

---@private
---@param checkbox render.md.CustomCheckbox
function Render:checkbox(checkbox)
    if not self.config.checkbox.enabled then
        return
    end

    local inline = self.config.checkbox.position == 'inline'
    local icon, highlight = checkbox.rendered, checkbox.highlight
    local added = self.marks:add('check_icon', self.info.start_row, self.info.start_col, {
        end_row = self.info.end_row,
        end_col = self.info.end_col,
        virt_text = { { inline and icon or str.pad_to(self.info.text, icon) .. icon, highlight } },
        virt_text_pos = 'inline',
        conceal = '',
    })

    if added then
        self.context:add_checkbox(self.info, checkbox)
    end
end

---@private
function Render:wiki_link()
    if not self.config.link.enabled then
        return
    end

    local parts = str.split(self.info.text:sub(2, -2), '|')
    local link_component = self:link_component(parts[1])
    local icon, highlight = self.config.link.wiki.icon, self.config.link.wiki.highlight
    if link_component ~= nil then
        icon, highlight = link_component.icon, link_component.highlight
    end
    local link_text = icon .. parts[#parts]
    local added = self.marks:add('link', self.info.start_row, self.info.start_col - 1, {
        end_row = self.info.end_row,
        end_col = self.info.end_col + 1,
        virt_text = { { link_text, highlight } },
        virt_text_pos = 'inline',
        conceal = '',
    })

    if added then
        self.context:add_offset(self.info, str.width(link_text) - str.width(self.info.text))
    end
end

return Render
