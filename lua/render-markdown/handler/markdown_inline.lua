local Context = require('render-markdown.context')
local NodeInfo = require('render-markdown.node_info')
local component = require('render-markdown.component')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local str = require('render-markdown.str')

---@class render.md.handler.buf.MarkdownInline
---@field private buf integer
---@field private marks render.md.Marks
---@field private config render.md.BufferConfig
---@field private context render.md.Context
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.MarkdownInline
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.buf = buf
    self.marks = list.new_marks()
    self.config = state.get_config(buf)
    self.context = Context.get(buf)
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    self.context:query(root, state.inline_query, function(capture, node)
        local info = NodeInfo.new(self.buf, node)
        logger.debug_node_info(capture, info)
        if capture == 'code' then
            self:code(info)
        elseif capture == 'shortcut' then
            self:shortcut(info)
        elseif capture == 'link' then
            self:link(info)
        else
            logger.unhandled_capture('inline', capture)
        end
    end)
    return self.marks:get()
end

---@private
---@param info render.md.NodeInfo
function Handler:code(info)
    local code = self.config.code
    if not code.enabled or not vim.tbl_contains({ 'normal', 'full' }, code.style) then
        return
    end
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        hl_group = code.highlight_inline,
    })
end

---@private
---@param info render.md.NodeInfo
function Handler:shortcut(info)
    local callout = component.callout(self.config, info.text, 'exact')
    if callout ~= nil then
        self:callout(info, callout)
        return
    end

    local checkbox = component.checkbox(self.config, info.text, 'exact')
    if checkbox ~= nil then
        self:checkbox(info, checkbox)
        return
    end

    if info:line('on'):find('[' .. info.text .. ']', 1, true) ~= nil then
        self:wiki_link(info)
        return
    end
end

---@private
---@param info render.md.NodeInfo
---@param callout render.md.CustomComponent
function Handler:callout(info, callout)
    if not self.config.quote.enabled then
        return
    end

    ---Support for overriding title: https://help.obsidian.md/Editing+and+formatting/Callouts#Change+the+title
    ---@return string, string?
    local function custom_title()
        local content = info:parent('inline')
        if content ~= nil then
            local line = str.split(content.text, '\n')[1]
            if #line > #callout.raw and vim.startswith(line:lower(), callout.raw:lower()) then
                local icon = str.split(callout.rendered, ' ')[1]
                local title = vim.trim(line:sub(#callout.raw + 1))
                return icon .. ' ' .. title, ''
            end
        end
        return callout.rendered, nil
    end

    local text, conceal = custom_title()
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { text, callout.highlight } },
        virt_text_pos = 'overlay',
        conceal = conceal,
    })
end

---@private
---@param info render.md.NodeInfo
---@param checkbox render.md.CustomComponent
function Handler:checkbox(info, checkbox)
    if not self.config.checkbox.enabled then
        return
    end
    local inline = self.config.checkbox.position == 'inline'
    local icon, highlight = checkbox.rendered, checkbox.highlight
    self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { inline and icon or str.pad_to(info.text, icon), highlight } },
        virt_text_pos = 'inline',
        conceal = '',
    })
end

---@private
---@param info render.md.NodeInfo
function Handler:wiki_link(info)
    if not self.config.link.enabled then
        return
    end
    local text = info.text:sub(2, -2)
    local parts = str.split(text, '|')
    local icon, highlight = self:dest_virt_text(parts[1])
    local link_text = icon .. parts[#parts]
    local added = self.marks:add(true, info.start_row, info.start_col - 1, {
        end_row = info.end_row,
        end_col = info.end_col + 1,
        virt_text = { { link_text, highlight } },
        virt_text_pos = 'inline',
        conceal = '',
    })
    if added then
        self.context:add_offset(info, str.width(link_text) - str.width(info.text))
    end
end

---@private
---@param info render.md.NodeInfo
function Handler:link(info)
    if not self.config.link.enabled then
        return
    end
    local icon, highlight = self:link_virt_text(info)
    local added = self.marks:add(true, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { icon, highlight } },
        virt_text_pos = 'inline',
    })
    if added then
        self.context:add_offset(info, str.width(icon))
    end
end

---@private
---@param info render.md.NodeInfo
---@return string, string
function Handler:link_virt_text(info)
    local link = self.config.link
    if info.type == 'image' then
        return link.image, link.highlight
    elseif info.type == 'inline_link' then
        local destination = info:child('link_destination')
        if destination ~= nil then
            return self:dest_virt_text(destination.text)
        end
    end
    return link.hyperlink, link.highlight
end

---@private
---@param destination string
---@return string, string
function Handler:dest_virt_text(destination)
    local link = self.config.link
    for _, link_component in pairs(link.custom) do
        if destination:find(link_component.pattern) then
            return link_component.icon, link_component.highlight
        end
    end
    return link.hyperlink, link.highlight
end

---@class render.md.handler.MarkdownInline: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
function M.parse(root, buf)
    return Handler.new(buf):parse(root)
end

return M
