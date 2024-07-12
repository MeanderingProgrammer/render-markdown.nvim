local component = require('render-markdown.component')
local icons = require('render-markdown.icons')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local shared = require('render-markdown.handler.shared')
local state = require('render-markdown.state')
local str = require('render-markdown.str')
local ts = require('render-markdown.ts')
local util = require('render-markdown.util')

---@class render.md.handler.Markdown
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
        local level = str.width(info.text)

        local icon = list.cycle(heading.icons, level)
        local background = list.clamp(heading.backgrounds, level)
        local foreground = list.clamp(heading.foregrounds, level)

        -- Available width is level + 1, where level = number of `#` characters and one is
        -- added to account for the space after the last `#` but before the heading title
        local padding = level + 1 - str.width(icon)

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

        local icon_text = icon .. ' '
        if ts.concealed(buf, info) > 0 then
            -- Fenced code blocks will pick up varying amounts of leading white space depending on
            -- the context they are in. This gets lumped into the delimiter node and as a result,
            -- after concealing, the extmark will be left shifted. Logic below accounts for this.
            local padding = 0
            local code_block = ts.parent_in_section(info.node, 'fenced_code_block')
            if code_block ~= nil then
                padding = str.leading_spaces(ts.info(code_block, buf).text)
            end
            icon_text = str.pad(icon_text .. info.text, padding)
        end

        local highlight = { icon_highlight }
        if code.style == 'full' then
            highlight = { icon_highlight, code.highlight }
        end

        vim.api.nvim_buf_set_extmark(buf, namespace, info.start_row, info.start_col, {
            virt_text = { { icon_text, highlight } },
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
            local leading_spaces = str.leading_spaces(info.text)
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
        M.render_table(namespace, buf, info)
    else
        -- Should only get here if user provides custom capture, currently unhandled
        logger.error('Unhandled markdown capture: ' .. capture)
    end
end

---@param namespace integer
---@param buf integer
---@param info render.md.NodeInfo
M.render_table = function(namespace, buf, info)
    local pipe_table = state.config.pipe_table
    if not pipe_table.enabled then
        return
    end
    if pipe_table.style == 'none' then
        return
    end
    local delim = nil
    local first = nil
    local last = nil
    for row_node in info.node:iter_children() do
        local row = ts.info(row_node, buf)
        if row.type == 'pipe_table_delimiter_row' then
            delim = row
            M.render_table_delimiter(namespace, buf, row)
        elseif row.type == 'pipe_table_header' then
            first = row
            M.render_table_row(namespace, buf, row, pipe_table.head)
        elseif row.type == 'pipe_table_row' then
            if last == nil or row.start_row > last.start_row then
                last = row
            end
            M.render_table_row(namespace, buf, row, pipe_table.row)
        else
            -- Should only get here if markdown introduces more row types, currently unhandled
            logger.error('Unhandled markdown row type: ' .. row.type)
        end
    end
    if pipe_table.style == 'full' then
        M.render_table_full(namespace, buf, delim, first, last)
    end
end

---@param namespace integer
---@param buf integer
---@param row render.md.NodeInfo
M.render_table_delimiter = function(namespace, buf, row)
    local pipe_table = state.config.pipe_table
    local border = pipe_table.border
    -- Order matters here, in particular handling inner intersections before left & right
    local delimiter = row.text
        :gsub(' ', '-')
        :gsub('%-|%-', border[11] .. border[5] .. border[11])
        :gsub('|%-', border[4] .. border[11])
        :gsub('%-|', border[11] .. border[6])
        :gsub('%-', border[11])

    vim.api.nvim_buf_set_extmark(buf, namespace, row.start_row, row.start_col, {
        end_row = row.end_row,
        end_col = row.end_col,
        virt_text = { { delimiter, pipe_table.head } },
        virt_text_pos = 'overlay',
    })
end

---@param namespace integer
---@param buf integer
---@param row render.md.NodeInfo
---@param highlight string
M.render_table_row = function(namespace, buf, row, highlight)
    local pipe_table = state.config.pipe_table
    if vim.tbl_contains({ 'raw', 'padded' }, pipe_table.cell) then
        for cell_node in row.node:iter_children() do
            local cell = ts.info(cell_node, buf)
            if cell.type == '|' then
                vim.api.nvim_buf_set_extmark(buf, namespace, cell.start_row, cell.start_col, {
                    end_row = cell.end_row,
                    end_col = cell.end_col,
                    virt_text = { { pipe_table.border[10], highlight } },
                    virt_text_pos = 'overlay',
                })
            elseif cell.type == 'pipe_table_cell' then
                -- Requires inline extmarks
                if pipe_table.cell == 'padded' and util.has_10 then
                    local offset = M.table_visual_offset(buf, cell)
                    if offset > 0 then
                        vim.api.nvim_buf_set_extmark(buf, namespace, cell.start_row, cell.end_col, {
                            virt_text = { { str.pad('', offset), pipe_table.filler } },
                            virt_text_pos = 'inline',
                        })
                    end
                end
            else
                -- Should only get here if markdown introduces more cell types, currently unhandled
                logger.error('Unhandled markdown cell type: ' .. cell.type)
            end
        end
    elseif pipe_table.cell == 'overlay' then
        vim.api.nvim_buf_set_extmark(buf, namespace, row.start_row, row.start_col, {
            end_row = row.end_row,
            end_col = row.end_col,
            virt_text = { { row.text:gsub('|', pipe_table.border[10]), highlight } },
            virt_text_pos = 'overlay',
        })
    end
end

---@param namespace integer
---@param buf integer
---@param delim? render.md.NodeInfo
---@param first? render.md.NodeInfo
---@param last? render.md.NodeInfo
M.render_table_full = function(namespace, buf, delim, first, last)
    local pipe_table = state.config.pipe_table
    local border = pipe_table.border
    if delim == nil or first == nil or last == nil then
        return
    end

    ---@param info render.md.NodeInfo
    ---@return integer
    local function width(info)
        local result = str.width(info.text)
        if pipe_table.cell == 'raw' then
            -- For the raw cell style we want the lengths to match after
            -- concealing & inlined elements
            result = result - M.table_visual_offset(buf, info)
        end
        return result
    end

    -- Do not need to account for concealed / inlined text on delimiter row
    local delim_width = str.width(delim.text)
    if delim_width ~= width(first) or delim_width ~= width(last) then
        return
    end

    local headings = vim.split(delim.text, '|', { plain = true, trimempty = true })
    local lengths = vim.tbl_map(function(cell)
        return border[11]:rep(str.width(cell))
    end, headings)

    local line_above = border[1] .. table.concat(lengths, border[2]) .. border[3]
    vim.api.nvim_buf_set_extmark(buf, namespace, first.start_row, first.start_col, {
        virt_lines_above = true,
        virt_lines = { { { line_above, pipe_table.head } } },
    })

    local line_below = border[7] .. table.concat(lengths, border[8]) .. border[9]
    vim.api.nvim_buf_set_extmark(buf, namespace, last.start_row, last.start_col, {
        virt_lines_above = false,
        virt_lines = { { { line_below, pipe_table.row } } },
    })
end

---@param buf integer
---@param info render.md.NodeInfo
---@return integer
M.table_visual_offset = function(buf, info)
    local result = ts.concealed(buf, info)
    local query = state.inline_link_query
    local tree = vim.treesitter.get_string_parser(info.text, 'markdown_inline')
    for id, node in query:iter_captures(tree:parse()[1]:root(), info.text) do
        if query.captures[id] == 'link' then
            local link_info = ts.info(node, info.text)
            result = result - str.width(shared.link_icon(link_info))
        end
    end
    return result
end

return M
