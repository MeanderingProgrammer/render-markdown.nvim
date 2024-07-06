local callout = require('render-markdown.callout')
local custom_checkbox = require('render-markdown.custom_checkbox')
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
    local highlights = state.config.highlights
    local value = vim.treesitter.get_node_text(node, buf)
    local start_row, start_col, end_row, end_col = node:range()
    logger.debug_node(capture, node, buf)

    if capture == 'heading' then
        local level = vim.fn.strdisplaywidth(value)

        local heading = list.cycle(state.config.headings, level)
        -- Available width is level + 1, where level = number of `#` characters and one is added
        -- to account for the space after the last `#` but before the heading title
        local padding = level + 1 - vim.fn.strdisplaywidth(heading)

        local background = list.clamp_last(highlights.heading.backgrounds, level)
        local foreground = list.clamp_last(highlights.heading.foregrounds, level)

        local heading_text = { str.pad(heading, padding), { foreground, background } }
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, 0, {
            end_row = end_row + 1,
            end_col = 0,
            hl_group = background,
            virt_text = { heading_text },
            virt_text_pos = 'overlay',
            hl_eol = true,
        })
    elseif capture == 'dash' then
        local width = vim.api.nvim_win_get_width(util.buf_to_win(buf))
        local dash_text = { state.config.dash:rep(width), highlights.dash }
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, 0, {
            virt_text = { dash_text },
            virt_text_pos = 'overlay',
        })
    elseif capture == 'code' then
        if state.config.code_style == 'none' then
            return
        end

        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, 0, {
            end_row = end_row,
            end_col = 0,
            hl_group = highlights.code,
            hl_eol = true,
        })
    elseif capture == 'language' then
        if state.config.code_style ~= 'full' then
            return
        end
        -- Requires inline extmarks
        if not util.has_10 then
            return
        end

        local icon, icon_highlight = icons.get(value)
        if icon == nil or icon_highlight == nil then
            return
        end

        local icon_text = { icon .. ' ' .. value, { icon_highlight, highlights.code } }
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            virt_text = { icon_text },
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
            -- List markers from tree-sitter should have leading spaces removed, however there are known
            -- edge cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
            -- As a result we handle leading spaces here, can remove if this gets fixed upstream
            local _, leading_spaces = value:find('^%s*')
            local level = ts.level_in_section(node, 'list')
            local bullet = list.cycle(state.config.bullets, level)

            local list_marker_text = { str.pad(bullet, leading_spaces), highlights.bullet }
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { list_marker_text },
                virt_text_pos = 'overlay',
            })
        end
    elseif capture == 'quote' then
        local query = state.markdown_quote_query
        for id, nested_node in query:iter_captures(node, buf) do
            M.render_node(namespace, buf, query.captures[id], nested_node)
        end
    elseif capture == 'quote_marker' then
        local highlight = highlights.quote
        local quote = ts.parent_in_section(node, 'block_quote')
        if quote ~= nil then
            local key = callout.get_key_contains(vim.treesitter.get_node_text(quote, buf))
            if key ~= nil then
                highlight = highlights.callout[key]
            end
        end

        local quote_marker_text = { value:gsub('>', state.config.quote), highlight }
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            virt_text = { quote_marker_text },
            virt_text_pos = 'overlay',
        })
    elseif vim.tbl_contains({ 'checkbox_unchecked', 'checkbox_checked' }, capture) then
        local checkbox = state.config.checkbox.unchecked
        local highlight = highlights.checkbox.unchecked
        if capture == 'checkbox_checked' then
            checkbox = state.config.checkbox.checked
            highlight = highlights.checkbox.checked
        end

        local checkbox_text = { str.pad_to(value, checkbox), highlight }
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            virt_text = { checkbox_text },
            virt_text_pos = 'overlay',
        })
    elseif capture == 'table' then
        if state.config.table_style ~= 'full' then
            return
        end

        ---@param row integer
        ---@param s string
        ---@return integer
        local function get_table_row_width(row, s)
            local result = vim.fn.strdisplaywidth(s)
            if state.config.cell_style == 'raw' then
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
                return string.rep('─', vim.fn.strdisplaywidth(part))
            end, headings)

            local line_above = { { '┌' .. table.concat(lengths, '┬') .. '┐', highlights.table.head } }
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                virt_lines_above = true,
                virt_lines = { line_above },
            })

            local line_below = { { '└' .. table.concat(lengths, '┴') .. '┘', highlights.table.row } }
            vim.api.nvim_buf_set_extmark(buf, namespace, end_row, start_col, {
                virt_lines_above = true,
                virt_lines = { line_below },
            })
        end
    elseif vim.tbl_contains({ 'table_head', 'table_delim', 'table_row' }, capture) then
        if state.config.table_style == 'none' then
            return
        end

        local highlight = highlights.table.head
        if capture == 'table_row' then
            highlight = highlights.table.row
        end

        if capture == 'table_delim' then
            -- Order matters here, in particular handling inner intersections before left & right
            local row = value
                :gsub('|', '│')
                :gsub('-', '─')
                :gsub(' ', '─')
                :gsub('─│─', '─┼─')
                :gsub('│─', '├─')
                :gsub('─│', '─┤')

            local table_delim_text = { row, highlight }
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { table_delim_text },
                virt_text_pos = 'overlay',
            })
        elseif state.config.cell_style == 'overlay' then
            local table_row_text = { value:gsub('|', '│'), highlight }
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { table_row_text },
                virt_text_pos = 'overlay',
            })
        elseif state.config.cell_style == 'raw' then
            for i = 1, #value do
                local ch = value:sub(i, i)
                if ch == '|' then
                    local table_pipe_text = { '│', highlight }
                    vim.api.nvim_buf_set_extmark(buf, namespace, start_row, i - 1, {
                        end_row = end_row,
                        end_col = i - 1,
                        virt_text = { table_pipe_text },
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
    if custom_checkbox.get_starts(vim.treesitter.get_node_text(paragraph, buf)) ~= nil then
        return true
    end
    return false
end

return M
