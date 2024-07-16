local component = require('render-markdown.component')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local shared = require('render-markdown.handler.shared')
local state = require('render-markdown.state')
local str = require('render-markdown.str')
local ts = require('render-markdown.ts')
local util = require('render-markdown.util')

---@class render.md.handler.MarkdownInline: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
M.parse = function(root, buf)
    local marks = {}
    local query = state.inline_query
    for id, node in query:iter_captures(root, buf) do
        local capture = query.captures[id]
        local info = ts.info(node, buf)
        logger.debug_node_info(capture, info)
        if capture == 'code' then
            list.add(marks, M.render_code(info))
        elseif capture == 'callout' then
            list.add(marks, M.render_callout(info))
        elseif capture == 'link' then
            list.add(marks, M.render_link(info))
        else
            logger.unhandled_capture('inline', capture)
        end
    end
    return marks
end

---@private
---@param info render.md.NodeInfo
---@return render.md.Mark?
M.render_code = function(info)
    local code = state.config.code
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
            hl_group = code.highlight,
        },
    }
end

---@private
---@param info render.md.NodeInfo
---@return render.md.Mark?
M.render_callout = function(info)
    local callout = component.callout(info.text, 'exact')
    if callout ~= nil then
        if not state.config.quote.enabled then
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
                virt_text = { { callout.text, callout.highlight } },
                virt_text_pos = 'overlay',
            },
        }
    else
        if not state.config.checkbox.enabled then
            return nil
        end
        -- Requires inline extmarks
        if not util.has_10 then
            return nil
        end
        local checkbox = component.checkbox(info.text, 'exact')
        if checkbox == nil then
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
                virt_text = { { str.pad_to(info.text, checkbox.text), checkbox.highlight } },
                virt_text_pos = 'inline',
                conceal = '',
            },
        }
    end
end

---@private
---@param info render.md.NodeInfo
---@return render.md.Mark?
M.render_link = function(info)
    local icon = shared.link_icon(info)
    if icon == nil then
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
            virt_text = { { icon, state.config.link.highlight } },
            virt_text_pos = 'inline',
        },
    }
end

return M
