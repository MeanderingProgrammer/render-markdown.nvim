local component = require('render-markdown.component')
local icons = require('render-markdown.icons')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')
local str = require('render-markdown.str')
local ts = require('render-markdown.ts')
local util = require('render-markdown.util')

local M = {}

---@param namespace integer
---@param root TSNode
---@param buf integer
M.render = function(namespace, root, buf)
    local query = state.markdown_query
    for id, node in query:iter_captures(root, buf) do
        M.render_node(namespace, buf, query.captures[id], node)
    end
end

---@param namespace integer
---@param buf integer
---@param capture string
---@param node TSNode
M.render_node = function(namespace, buf, capture, node)
    local value = vim.treesitter.get_node_text(node, buf)
    local start_row, start_col, end_row, end_col = node:range()
    logger.debug_node(capture, node, buf)

    if capture == 'heading' then
        local heading = state.config.heading
        local level = vim.fn.strdisplaywidth(value)

        local icon = list.cycle(heading.icons, level)
        -- Available width is level + 1, where level = number of `#` characters and one is added
        -- to account for the space after the last `#` but before the heading title
        local padding = level + 1 - vim.fn.strdisplaywidth(icon)

        local background = list.clamp(heading.backgrounds, level)
        local foreground = list.clamp(heading.foregrounds, level)

        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, 0, {
            end_row = end_row + 1,
            end_col = 0,
            hl_group = background,
            virt_text = { { str.pad(icon, padding), { foreground, background } } },
            virt_text_pos = 'overlay',
            hl_eol = true,
        })

        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            sign_text = list.cycle(heading.signs, level),
            sign_hl_group = foreground,
        })
    elseif capture == 'dash' then
        local dash = state.config.dash
        local width = vim.api.nvim_win_get_width(util.buf_to_win(buf))

        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, 0, {
            virt_text = { { dash.icon:rep(width), dash.highlight } },
            virt_text_pos = 'overlay',
        })
    elseif capture == 'code' then
        local code = state.config.code
        if not vim.tbl_contains({ 'normal', 'full' }, code.style) then
            return
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, 0, {
            end_row = end_row,
            end_col = 0,
            hl_group = code.highlight,
            hl_eol = true,
        })
    elseif capture == 'language' then
        local code = state.config.code
        if not vim.tbl_contains({ 'language', 'full' }, code.style) then
            return
        end
        local icon, icon_highlight = icons.get(value)
        if icon == nil or icon_highlight == nil then
            return
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            sign_text = icon,
            sign_hl_group = icon_highlight,
        })
        -- Requires inline extmarks
        if not util.has_10 then
            return
        end
        local highlight = { icon_highlight }
        if code.style == 'full' then
            highlight = { icon_highlight, code.highlight }
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            virt_text = { { icon .. ' ' .. value, highlight } },
            virt_text_pos = 'inline',
        })
    elseif capture == 'list_marker' then
        if M.sibling_checkbox(buf, node) then
            -- Hide the list marker for checkboxes rather than replacing with a bullet point
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                conceal = '',
            })
        else
            local bullet = state.config.bullet
            -- List markers from tree-sitter should have leading spaces removed, however there are known
            -- edge cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
            -- As a result we handle leading spaces here, can remove if this gets fixed upstream
            local _, leading_spaces = value:find('^%s*')
            local level = ts.level_in_section(node, 'list')
            local icon = list.cycle(bullet.icons, level)

            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { { str.pad(icon, leading_spaces), bullet.highlight } },
                virt_text_pos = 'overlay',
            })
        end
    elseif capture == 'quote' then
        local query = state.markdown_quote_query
        for id, nested_node in query:iter_captures(node, buf) do
            M.render_node(namespace, buf, query.captures[id], nested_node)
        end
    elseif capture == 'quote_marker' then
        local quote = state.config.quote
        local highlight = quote.highlight
        local quote_node = ts.parent_in_section(node, 'block_quote')
        if quote_node ~= nil then
            local callout = component.callout(vim.treesitter.get_node_text(quote_node, buf), 'contains')
            if callout ~= nil then
                highlight = callout.highlight
            end
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            virt_text = { { value:gsub('>', quote.icon), highlight } },
            virt_text_pos = 'overlay',
        })
    elseif vim.tbl_contains({ 'checkbox_unchecked', 'checkbox_checked' }, capture) then
        local checkbox = state.config.checkbox.unchecked
        if capture == 'checkbox_checked' then
            checkbox = state.config.checkbox.checked
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            virt_text = { { str.pad_to(value, checkbox.icon), checkbox.highlight } },
            virt_text_pos = 'overlay',
        })
    elseif capture == 'table' then
        local pipe_table = state.config.pipe_table
        if pipe_table.style ~= 'full' then
            return
        end
        local border = pipe_table.border

        ---@param row integer
        ---@param s string
        ---@return integer
        local function get_table_row_width(row, s)
            local result = vim.fn.strdisplaywidth(s)
            if pipe_table.cell == 'raw' then
                result = result - ts.concealed(buf, row, s)
            end
            return result
        end

        local delim = ts.child(node, 'pipe_table_delimiter_row')
        if delim == nil then
            return
        end
        local delim_row, _, _, _ = delim:range()
        local delim_value = vim.treesitter.get_node_text(delim, buf)
        local delim_width = get_table_row_width(delim_row, delim_value)

        local lines = vim.api.nvim_buf_get_lines(buf, start_row, end_row, true)
        local start_width = get_table_row_width(start_row, list.first(lines))
        local end_width = get_table_row_width(end_row - 1, list.last(lines))

        if delim_width == start_width and start_width == end_width then
            local headings = vim.split(delim_value, '|', { plain = true, trimempty = true })
            local lengths = vim.tbl_map(function(part)
                return border[11]:rep(vim.fn.strdisplaywidth(part))
            end, headings)

            local line_above = border[1] .. table.concat(lengths, border[2]) .. border[3]
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                virt_lines_above = true,
                virt_lines = { { { line_above, pipe_table.head } } },
            })

            local line_below = border[7] .. table.concat(lengths, border[8]) .. border[9]
            vim.api.nvim_buf_set_extmark(buf, namespace, end_row, start_col, {
                virt_lines_above = true,
                virt_lines = { { { line_below, pipe_table.row } } },
            })
        end
    elseif vim.tbl_contains({ 'table_head', 'table_delim', 'table_row' }, capture) then
        local pipe_table = state.config.pipe_table
        if pipe_table.style == 'none' then
            return
        end
        local border = pipe_table.border

        local highlight = pipe_table.head
        if capture == 'table_row' then
            highlight = pipe_table.row
        end

        if capture == 'table_delim' then
            -- Order matters here, in particular handling inner intersections before left & right
            local row = value
                :gsub(' ', '-')
                :gsub('%-|%-', border[11] .. border[5] .. border[11])
                :gsub('|%-', border[4] .. border[11])
                :gsub('%-|', border[11] .. border[6])
                :gsub('%-', border[11])

            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { { row, highlight } },
                virt_text_pos = 'overlay',
            })
        elseif pipe_table.cell == 'overlay' then
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { { value:gsub('|', border[10]), highlight } },
                virt_text_pos = 'overlay',
            })
        elseif pipe_table.cell == 'raw' then
            for i = 1, #value do
                if value:sub(i, i) == '|' then
                    vim.api.nvim_buf_set_extmark(buf, namespace, start_row, i - 1, {
                        end_row = end_row,
                        end_col = i - 1,
                        virt_text = { { border[10], highlight } },
                        virt_text_pos = 'overlay',
                    })
                end
            end
        end
    else
        -- Should only get here if user provides custom capture, currently unhandled
        logger.error('Unhandled markdown capture: ' .. capture)
    end
end

---@param buf integer
---@param node TSNode
---@return boolean
M.sibling_checkbox = function(buf, node)
    if ts.sibling(node, { 'task_list_marker_unchecked', 'task_list_marker_checked' }) ~= nil then
        return true
    end
    local paragraph = ts.sibling(node, { 'paragraph' })
    if paragraph == nil then
        return false
    end
    if component.checkbox(vim.treesitter.get_node_text(paragraph, buf), 'starts') ~= nil then
        return true
    end
    return false
end

return M
