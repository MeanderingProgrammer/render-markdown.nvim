local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local state = require('render-markdown.state')

local M = {}

---@param namespace number
---@param root TSNode
M.render = function(namespace, root)
    local highlights = state.config.highlights
    ---@diagnostic disable-next-line: missing-parameter
    for id, node in state.markdown_query:iter_captures(root, 0) do
        local capture = state.markdown_query.captures[id]
        local value = vim.treesitter.get_node_text(node, 0)
        local start_row, start_col, end_row, end_col = node:range()
        logger.debug_node(capture, node)

        if capture == 'heading' then
            local level = #value

            local heading = list.cycle(state.config.headings, level)
            -- Available width is level + 1, where level = number of `#` characters and one is added
            -- to account for the space after the last `#` but before the heading title
            local padding = level + 1 - vim.fn.strdisplaywidth(heading)

            local background = list.clamp_last(highlights.heading.backgrounds, level)
            local foreground = list.clamp_last(highlights.heading.foregrounds, level)

            local virt_text = { string.rep(' ', padding) .. heading, { foreground, background } }
            vim.api.nvim_buf_set_extmark(0, namespace, start_row, 0, {
                end_row = end_row + 1,
                end_col = 0,
                hl_group = background,
                virt_text = { virt_text },
                virt_text_pos = 'overlay',
                hl_eol = true,
            })
        elseif capture == 'dash' then
            local width = vim.api.nvim_win_get_width(0)
            local virt_text = { state.config.dash:rep(width), highlights.dash }
            vim.api.nvim_buf_set_extmark(0, namespace, start_row, 0, {
                virt_text = { virt_text },
                virt_text_pos = 'overlay',
            })
        elseif capture == 'code' then
            vim.api.nvim_buf_set_extmark(0, namespace, start_row, 0, {
                end_row = end_row,
                end_col = 0,
                hl_group = highlights.code,
                hl_eol = true,
            })
        elseif capture == 'list_marker' then
            local list_marker_overlay = ''
            if M.is_sibling_checkbox(node) then
                -- Hide the list marker for checkboxes rather than replacing with a bullet point
                list_marker_overlay = string.rep(' ', #value)
            else
                -- List markers from tree-sitter should have leading spaces removed, however there are known
                -- edge cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
                -- As a result we handle leading spaces here, can remove if this gets fixed upstream
                local _, leading_spaces = value:find('^%s*')
                local level = M.calculate_list_level(node)
                local bullet = list.cycle(state.config.bullets, level)
                list_marker_overlay = string.rep(' ', leading_spaces or 0) .. bullet
            end

            local virt_text = { list_marker_overlay, highlights.bullet }
            vim.api.nvim_buf_set_extmark(0, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { virt_text },
                virt_text_pos = 'overlay',
            })
        elseif capture == 'quote_marker' then
            local virt_text = { value:gsub('>', state.config.quote), highlights.quote }
            vim.api.nvim_buf_set_extmark(0, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { virt_text },
                virt_text_pos = 'overlay',
            })
        elseif vim.tbl_contains({ 'checkbox_unchecked', 'checkbox_checked' }, capture) then
            local checkbox = state.config.checkbox.unchecked
            local highlight = highlights.checkbox.unchecked
            if capture == 'checkbox_checked' then
                checkbox = state.config.checkbox.checked
                highlight = highlights.checkbox.checked
            end
            local padding = vim.fn.strdisplaywidth(value) - vim.fn.strdisplaywidth(checkbox)

            if padding >= 0 then
                local virt_text = { string.rep(' ', padding) .. checkbox, highlight }
                vim.api.nvim_buf_set_extmark(0, namespace, start_row, start_col, {
                    end_row = end_row,
                    end_col = end_col,
                    virt_text = { virt_text },
                    virt_text_pos = 'overlay',
                })
            end
        elseif capture == 'table' then
            if state.config.fat_tables then
                local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
                local table_head = list.first(lines)
                local table_tail = list.last(lines)
                if #table_head == #table_tail then
                    local headings = vim.split(table_head, '|', { plain = true, trimempty = true })
                    local sections = vim.tbl_map(function(part)
                        return string.rep('─', #part)
                    end, headings)

                    local line_above = { { '┌' .. table.concat(sections, '┬') .. '┐', highlights.table.head } }
                    vim.api.nvim_buf_set_extmark(0, namespace, start_row, start_col, {
                        virt_lines_above = true,
                        virt_lines = { line_above },
                    })

                    local line_below = { { '└' .. table.concat(sections, '┴') .. '┘', highlights.table.row } }
                    vim.api.nvim_buf_set_extmark(0, namespace, end_row, start_col, {
                        virt_lines_above = true,
                        virt_lines = { line_below },
                    })
                end
            end
        elseif vim.tbl_contains({ 'table_head', 'table_delim', 'table_row' }, capture) then
            local row = value:gsub('|', '│')
            if capture == 'table_delim' then
                -- Order matters here, in particular handling inner intersections before left & right
                row = row:gsub('-', '─')
                    :gsub(' ', '─')
                    :gsub('─│─', '─┼─')
                    :gsub('│─', '├─')
                    :gsub('─│', '─┤')
            end

            local highlight = highlights.table.head
            if capture == 'table_row' then
                highlight = highlights.table.row
            end

            local virt_text = { row, highlight }
            vim.api.nvim_buf_set_extmark(0, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { virt_text },
                virt_text_pos = 'overlay',
            })
        else
            -- Should only get here if user provides custom capture, currently unhandled
            logger.error('Unhandled markdown capture: ' .. capture)
        end
    end
end

---@param node TSNode
---@return boolean
M.is_sibling_checkbox = function(node)
    local sibling = node:next_sibling()
    if sibling == nil then
        return false
    end
    return vim.startswith(sibling:type(), 'task_list_marker')
end

--- Walk through all parent nodes and count the number of nodes with type list
--- to calculate the level of the given node
---@param node TSNode
---@return integer
M.calculate_list_level = function(node)
    local level = 0
    local parent = node:parent()
    while parent ~= nil do
        local parent_type = parent:type()
        if vim.tbl_contains({ 'section', 'document' }, parent_type) then
            -- when reaching a section or the document we are clearly at the
            -- top of the list
            break
        elseif parent_type == 'list' then
            -- found a list increase the level and continue
            level = level + 1
        end
        parent = parent:parent()
    end
    return level
end

return M
