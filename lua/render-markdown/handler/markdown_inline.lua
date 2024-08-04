local component = require('render-markdown.component')
local context = require('render-markdown.context')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local str = require('render-markdown.str')
local ts = require('render-markdown.ts')
local util = require('render-markdown.util')

---@class render.md.handler.MarkdownInline: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
function M.parse(root, buf)
    local config = state.get_config(buf)
    local marks = {}
    context.get(buf):query(root, state.inline_query, function(capture, node)
        local info = ts.info(node, buf)
        logger.debug_node_info(capture, info)
        if capture == 'code' then
            list.add_mark(marks, M.code(config, info))
        elseif capture == 'shortcut' then
            list.add_mark(marks, M.shortcut(config, buf, info))
        elseif capture == 'link' then
            list.add_mark(marks, M.link(config, buf, info))
        else
            logger.unhandled_capture('inline', capture)
        end
    end)
    return marks
end

---@private
---@param config render.md.BufferConfig
---@param info render.md.NodeInfo
---@return render.md.Mark?
function M.code(config, info)
    local code = config.code
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
---@param config render.md.BufferConfig
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark?
function M.shortcut(config, buf, info)
    local callout = component.callout(config, info.text, 'exact')
    if callout ~= nil then
        return M.callout(config, buf, info, callout)
    end
    local checkbox = component.checkbox(config, info.text, 'exact')
    if checkbox ~= nil then
        return M.checkbox(config, info, checkbox)
    end
    local line = vim.api.nvim_buf_get_lines(buf, info.start_row, info.start_row + 1, false)[1]
    if line:find('[' .. info.text .. ']', 1, true) ~= nil then
        return M.wiki_link(config, info)
    end
    return nil
end

---@private
---@param config render.md.BufferConfig
---@param buf integer
---@param info render.md.NodeInfo
---@param callout render.md.CustomComponent
---@return render.md.Mark?
function M.callout(config, buf, info, callout)
    ---Support for overriding title: https://help.obsidian.md/Editing+and+formatting/Callouts#Change+the+title
    ---@return string, string?
    local function custom_title()
        local content = ts.parent(buf, info, 'inline')
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

    if not config.quote.enabled then
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
---@param config render.md.BufferConfig
---@param info render.md.NodeInfo
---@param checkbox render.md.CustomComponent
---@return render.md.Mark?
function M.checkbox(config, info, checkbox)
    if not config.checkbox.enabled then
        return nil
    end
    -- Requires inline extmarks
    if not util.has_10 then
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
---@param config render.md.BufferConfig
---@param info render.md.NodeInfo
---@return render.md.Mark?
function M.wiki_link(config, info)
    local link = config.link
    if not link.enabled then
        return nil
    end
    -- Requires inline extmarks
    if not util.has_10 then
        return nil
    end
    local text = info.text:sub(2, -2)
    local elements = str.split(text, '|')
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col - 1,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col + 1,
            virt_text = { { link.hyperlink .. elements[#elements], link.highlight } },
            virt_text_pos = 'inline',
            conceal = '',
        },
    }
end

---@private
---@param config render.md.BufferConfig
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark?
function M.link(config, buf, info)
    local link = config.link
    if not link.enabled then
        return nil
    end
    -- Requires inline extmarks
    if not util.has_10 then
        return nil
    end
    local icon = nil
    if vim.tbl_contains({ 'inline_link', 'full_reference_link' }, info.type) then
        icon = link.hyperlink
    elseif info.type == 'image' then
        icon = link.image
    end
    if icon == nil then
        return nil
    end
    context.get(buf):add_link(info, icon)
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { icon, link.highlight } },
            virt_text_pos = 'inline',
        },
    }
end

return M
