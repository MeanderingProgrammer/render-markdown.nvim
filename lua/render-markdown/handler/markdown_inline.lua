local component = require('render-markdown.component')
local context = require('render-markdown.context')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local str = require('render-markdown.str')
local ts = require('render-markdown.ts')
local util = require('render-markdown.util')

---@class render.md.handler.buf.MarkdownInline
---@field private buf integer
---@field private config render.md.BufferConfig
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.MarkdownInline
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.buf = buf
    self.config = state.get_config(buf)
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    local marks = {}
    context.get(self.buf):query(root, state.inline_query, function(capture, node)
        local info = ts.info(node, self.buf)
        logger.debug_node_info(capture, info)
        if capture == 'code' then
            list.add_mark(marks, self:code(info))
        elseif capture == 'shortcut' then
            list.add_mark(marks, self:shortcut(info))
        elseif capture == 'link' then
            list.add_mark(marks, self:link(info))
        else
            logger.unhandled_capture('inline', capture)
        end
    end)
    return marks
end

---@private
---@param info render.md.NodeInfo
---@return render.md.Mark?
function Handler:code(info)
    local code = self.config.code
    if not code.enabled then
        return nil
    end
    if not vim.tbl_contains({ 'normal', 'full' }, code.style) then
        return nil
    end
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col,
            hl_group = code.highlight_inline,
        },
    }
end

---@private
---@param info render.md.NodeInfo
---@return render.md.Mark?
function Handler:shortcut(info)
    local callout = component.callout(self.config, info.text, 'exact')
    if callout ~= nil then
        return self:callout(info, callout)
    end
    local checkbox = component.checkbox(self.config, info.text, 'exact')
    if checkbox ~= nil then
        return self:checkbox(info, checkbox)
    end
    local line = vim.api.nvim_buf_get_lines(self.buf, info.start_row, info.start_row + 1, false)[1]
    if line:find('[' .. info.text .. ']', 1, true) ~= nil then
        return self:wiki_link(info)
    end
    return nil
end

---@private
---@param info render.md.NodeInfo
---@param callout render.md.CustomComponent
---@return render.md.Mark?
function Handler:callout(info, callout)
    ---Support for overriding title: https://help.obsidian.md/Editing+and+formatting/Callouts#Change+the+title
    ---@return string, string?
    local function custom_title()
        local content = ts.parent(self.buf, info, 'inline')
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

    if not self.config.quote.enabled then
        return nil
    end
    local text, conceal = custom_title()
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { text, callout.highlight } },
            virt_text_pos = 'overlay',
            conceal = conceal,
        },
    }
end

---@private
---@param info render.md.NodeInfo
---@param checkbox render.md.CustomComponent
---@return render.md.Mark?
function Handler:checkbox(info, checkbox)
    -- Requires inline extmarks
    if not self.config.checkbox.enabled or not util.has_10 then
        return nil
    end
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { str.pad_to(info.text, checkbox.rendered), checkbox.highlight } },
            virt_text_pos = 'inline',
            conceal = '',
        },
    }
end

---@private
---@param info render.md.NodeInfo
---@return render.md.Mark?
function Handler:wiki_link(info)
    -- Requires inline extmarks
    if not self.config.link.enabled or not util.has_10 then
        return nil
    end
    local text = info.text:sub(2, -2)
    local parts = str.split(text, '|')
    local icon, highlight = self:destination_info(parts[1])
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col - 1,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col + 1,
            virt_text = { { icon .. parts[#parts], highlight } },
            virt_text_pos = 'inline',
            conceal = '',
        },
    }
end

---@private
---@param info render.md.NodeInfo
---@return render.md.Mark?
function Handler:link(info)
    local link = self.config.link
    -- Requires inline extmarks
    if not link.enabled or not util.has_10 then
        return nil
    end
    local icon, highlight
    if info.type == 'inline_link' then
        local destination = ts.child(self.buf, info, 'link_destination')
        if destination ~= nil then
            icon, highlight = self:destination_info(destination.text)
        else
            icon, highlight = link.hyperlink, link.highlight
        end
    elseif info.type == 'full_reference_link' then
        icon, highlight = link.hyperlink, link.highlight
    elseif info.type == 'image' then
        icon, highlight = link.image, link.highlight
    else
        return nil
    end
    context.get(self.buf):add_link(info, icon)
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { icon, highlight } },
            virt_text_pos = 'inline',
        },
    }
end

---@private
---@param destination string
---@return string, string
function Handler:destination_info(destination)
    local link_component = component.link(self.config, destination)
    if link_component == nil then
        return self.config.link.hyperlink, self.config.link.highlight
    else
        return link_component.icon, link_component.highlight
    end
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
