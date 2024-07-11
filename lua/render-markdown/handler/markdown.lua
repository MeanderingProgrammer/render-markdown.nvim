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
    local info = ts.info(node, buf)
    logger.debug_node_info(capture, info)

    if capture == 'heading' then
        local heading = state.config.heading
        if not heading.enabled then
            return
        end
        local level = vim.fn.strdisplaywidth(info.text)

        local icon = list.cycle(heading.icons, level)
        local background = list.clamp(heading.backgrounds, level)
        local foreground = list.clamp(heading.foregrounds, level)

        -- Available width is level + 1, where level = number of `#` characters and one is
        -- added to account for the space after the last `#` but before the heading title
        local padding = level + 1 - vim.fn.strdisplaywidth(icon)

        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, 0, {
            end_row = info.end_row + 1,
            end_col = 0,
            hl_group = background,
            virt_text = { { str.pad(icon, padding), { foreground, background } } },
            virt_text_pos = 'overlay',
            hl_eol = true,
        })

        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
            sign_text = list.cycle(heading.signs, level),
            sign_hl_group = foreground,
        })
    elseif capture == 'dash' then
        local dash = state.config.dash
        if not dash.enabled then
            return
        end
        local width = vim.api.nvim_win_get_width(util.buf_to_win(buf))
        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, 0, {
            virt_text = { { dash.icon:rep(width), dash.highlight } },
            virt_text_pos = 'overlay',
        })
    elseif capture == 'code' then
        local code = state.config.code
        if not code.enabled then
            return
        end
        if not vim.tbl_contains({ 'normal', 'full' }, code.style) then
            return
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, 0, {
            end_row = info.end_row,
            end_col = 0,
            hl_group = code.highlight,
            hl_eol = true,
        })
    elseif capture == 'language' then
        local code = state.config.code
        if not code.enabled then
            return
        end
        if not vim.tbl_contains({ 'language', 'full' }, code.style) then
            return
        end
        local icon, icon_highlight = icons.get(info.text)
        if icon == nil or icon_highlight == nil then
            return
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
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
        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
            virt_text = { { icon .. ' ' .. info.text, highlight } },
            virt_text_pos = 'inline',
        })
    elseif capture == 'list_marker' then
        ---@return boolean
        local function sibling_checkbox()
            if not state.config.checkbox.enabled then
                return false
            end
            if ts.sibling(info.node, 'task_list_marker_unchecked') ~= nil then
                return true
            end
            if ts.sibling(info.node, 'task_list_marker_checked') ~= nil then
                return true
            end
            local paragraph_node = ts.sibling(info.node, 'paragraph')
            if paragraph_node == nil then
                return false
            end
            local paragraph = ts.info(paragraph_node, buf)
            return component.checkbox(paragraph.text, 'starts') ~= nil
        end

        if sibling_checkbox() then
            -- Hide the list marker for checkboxes rather than replacing with a bullet point
            vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
                end_row = info.end_row,
                end_col = info.end_col,
                conceal = '',
            })
        else
            local bullet = state.config.bullet
            if not bullet.enabled then
                return
            end
            -- List markers from tree-sitter should have leading spaces removed, however there are known
            -- edge cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
            -- As a result we handle leading spaces here, can remove if this gets fixed upstream
            local _, leading_spaces = info.text:find('^%s*')
            local level = ts.level_in_section(info.node, 'list')
            local icon = list.cycle(bullet.icons, level)

            vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
                end_row = info.end_row,
                end_col = info.end_col,
                virt_text = { { str.pad(icon, leading_spaces), bullet.highlight } },
                virt_text_pos = 'overlay',
            })
        end
    elseif capture == 'quote' then
        local query = state.markdown_quote_query
        for id, nested_node in query:iter_captures(info.node, buf) do
            M.render_node(namespace, buf, query.captures[id], nested_node)
        end
    elseif capture == 'quote_marker' then
        local quote = state.config.quote
        if not quote.enabled then
            return
        end
        local highlight = quote.highlight
        local quote_node = ts.parent_in_section(info.node, 'block_quote')
        if quote_node ~= nil then
            local callout = component.callout(ts.info(quote_node, buf).text, 'contains')
            if callout ~= nil then
                highlight = callout.highlight
            end
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { info.text:gsub('>', quote.icon), highlight } },
            virt_text_pos = 'overlay',
        })
    elseif vim.tbl_contains({ 'checkbox_unchecked', 'checkbox_checked' }, capture) then
        local checkbox = state.config.checkbox
        if not checkbox.enabled then
            return
        end
        local checkbox_state = checkbox.unchecked
        if capture == 'checkbox_checked' then
            checkbox_state = checkbox.checked
        end
        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { str.pad_to(info.text, checkbox_state.icon), checkbox_state.highlight } },
            virt_text_pos = 'overlay',
        })
    elseif capture == 'table' then
        local pipe_table = state.config.pipe_table
        if not pipe_table.enabled then
            return
        end
        if pipe_table.style == 'none' then
            return
        end
        local border = pipe_table.border

        local function render_table_full()
            local delim_node = ts.child(info.node, 'pipe_table_delimiter_row')
            if delim_node == nil then
                return
            end

            ---@param row integer
            ---@param s string
            ---@return integer
            local function get_row_width(row, s)
                local result = vim.fn.strdisplaywidth(s)
                if pipe_table.cell == 'raw' then
                    result = result - ts.concealed(buf, row, s)
                end
                return result
            end

            local delim = ts.info(delim_node, buf)
            local delim_width = get_row_width(delim.start_row, delim.text)

            local lines = vim.api.nvim_buf_get_lines(buf, info.start_row, info.end_row, true)
            local start_width = get_row_width(info.start_row, list.first(lines))
            local end_width = get_row_width(info.end_row - 1, list.last(lines))

            if delim_width ~= start_width or start_width ~= end_width then
                return
            end

            local headings = vim.split(delim.text, '|', { plain = true, trimempty = true })
            local lengths = vim.tbl_map(function(part)
                return border[11]:rep(vim.fn.strdisplaywidth(part))
            end, headings)

            local line_above = border[1] .. table.concat(lengths, border[2]) .. border[3]
            vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
                virt_lines_above = true,
                virt_lines = { { { line_above, pipe_table.head } } },
            })

            local line_below = border[7] .. table.concat(lengths, border[8]) .. border[9]
            vim.api.nvim_buf_set_extmark(buf, namespace, info.end_row, info.start_col, {
                virt_lines_above = true,
                virt_lines = { { { line_below, pipe_table.row } } },
            })
        end

        ---@param row_info render.md.NodeInfo
        local function render_table_delimiter(row_info)
            -- Order matters here, in particular handling inner intersections before left & right
            local row = row_info.text
                :gsub(' ', '-')
                :gsub('%-|%-', border[11] .. border[5] .. border[11])
                :gsub('|%-', border[4] .. border[11])
                :gsub('%-|', border[11] .. border[6])
                :gsub('%-', border[11])

            vim.api.nvim_buf_set_extmark(buf, namespace, row_info.start_row, row_info.start_col, {
                end_row = row_info.end_row,
                end_col = row_info.end_col,
                virt_text = { { row, pipe_table.head } },
                virt_text_pos = 'overlay',
            })
        end

        ---@param row_info render.md.NodeInfo
        ---@param highlight string
        local function render_table_row(row_info, highlight)
            if pipe_table.cell == 'overlay' then
                vim.api.nvim_buf_set_extmark(buf, namespace, row_info.start_row, row_info.start_col, {
                    end_row = row_info.end_row,
                    end_col = row_info.end_col,
                    virt_text = { { row_info.text:gsub('|', border[10]), highlight } },
                    virt_text_pos = 'overlay',
                })
            elseif pipe_table.cell == 'raw' then
                for i = 1, #row_info.text do
                    if row_info.text:sub(i, i) == '|' then
                        vim.api.nvim_buf_set_extmark(buf, namespace, row_info.start_row, i - 1, {
                            end_row = row_info.end_row,
                            end_col = i - 1,
                            virt_text = { { border[10], highlight } },
                            virt_text_pos = 'overlay',
                        })
                    end
                end
            end
        end

        if pipe_table.style == 'full' then
            render_table_full()
        end

        for row in info.node:iter_children() do
            local row_info = ts.info(row, buf)
            local row_type = row_info.node:type()
            if row_type == 'pipe_table_delimiter_row' then
                render_table_delimiter(row_info)
            elseif row_type == 'pipe_table_header' then
                render_table_row(row_info, pipe_table.head)
            elseif row_type == 'pipe_table_row' then
                render_table_row(row_info, pipe_table.row)
            else
                -- Should only get here if markdown introduces more row types, currently unhandled
                logger.error('Unhandled markdown row type: ' .. row_type)
            end
        end
    else
        -- Should only get here if user provides custom capture, currently unhandled
        logger.error('Unhandled markdown capture: ' .. capture)
    end
end

return M
