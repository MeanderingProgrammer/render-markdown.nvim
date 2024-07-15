local component = require('render-markdown.component')
local logger = require('render-markdown.logger')
local shared = require('render-markdown.handler.shared')
local state = require('render-markdown.state')
local str = require('render-markdown.str')
local ts = require('render-markdown.ts')
local util = require('render-markdown.util')

---@class render.md.handler.MarkdownInline: render.md.Handler
local M = {}

---@param namespace integer
---@param root TSNode
---@param buf integer
M.render = function(namespace, root, buf)
    local query = state.inline_query
    for id, node in query:iter_captures(root, buf) do
        local capture = query.captures[id]
        local info = ts.info(node, buf)
        logger.debug_node_info(capture, info)
        if capture == 'code' then
            M.render_code(namespace, buf, info)
        elseif capture == 'callout' then
            M.render_callout(namespace, buf, info)
        elseif capture == 'link' then
            M.render_link(namespace, buf, info)
        else
            logger.unhandled_capture('inline', capture)
        end
    end
end

---@private
---@param namespace integer
---@param buf integer
---@param info render.md.NodeInfo
M.render_code = function(namespace, buf, info)
    local code = state.config.code
    if not code.enabled then
        return
    end
    if not vim.tbl_contains({ 'normal', 'full' }, code.style) then
        return
    end
    vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        hl_group = code.highlight,
    })
end

---@private
---@param namespace integer
---@param buf integer
---@param info render.md.NodeInfo
M.render_callout = function(namespace, buf, info)
    local callout = component.callout(info.text, 'exact')
    if callout ~= nil then
        if not state.config.quote.enabled then
            return
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { callout.text, callout.highlight } },
            virt_text_pos = 'overlay',
        })
    else
        if not state.config.checkbox.enabled then
            return
        end
        -- Requires inline extmarks
        if not util.has_10 then
            return
        end
        local checkbox = component.checkbox(info.text, 'exact')
        if checkbox == nil then
            return
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { str.pad_to(info.text, checkbox.text), checkbox.highlight } },
            virt_text_pos = 'inline',
            conceal = '',
        })
    end
end

---@private
---@param namespace integer
---@param buf integer
---@param info render.md.NodeInfo
M.render_link = function(namespace, buf, info)
    local icon = shared.link_icon(info)
    if icon == nil then
        return
    end
    vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
        end_row = info.end_row,
        end_col = info.end_col,
        virt_text = { { icon, state.config.link.highlight } },
        virt_text_pos = 'inline',
    })
end

return M
