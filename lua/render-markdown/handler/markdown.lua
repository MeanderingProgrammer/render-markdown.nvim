local colors = require('render-markdown.colors')
local component = require('render-markdown.component')
local icons = require('render-markdown.icons')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local shared = require('render-markdown.handler.shared')
local state = require('render-markdown.state')
local str = require('render-markdown.str')
local ts = require('render-markdown.ts')
local util = require('render-markdown.util')

---@class render.md.handler.Markdown: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
M.parse = function(root, buf)
    local marks = {}
    local query = state.markdown_query
    for id, node in query:iter_captures(root, buf) do
        local capture = query.captures[id]
        local info = ts.info(node, buf)
        logger.debug_node_info(capture, info)
        if capture == 'heading' then
            vim.list_extend(marks, M.render_heading(buf, info))
        elseif capture == 'dash' then
            list.add(marks, M.render_dash(buf, info))
        elseif capture == 'code' then
            vim.list_extend(marks, M.render_code(buf, info))
        elseif capture == 'list_marker' then
            list.add(marks, M.render_list_marker(buf, info))
        elseif capture == 'checkbox_unchecked' then
            list.add(marks, M.render_checkbox(info, state.config.checkbox.unchecked))
        elseif capture == 'checkbox_checked' then
            list.add(marks, M.render_checkbox(info, state.config.checkbox.checked))
        elseif capture == 'quote' then
            local quote_query = state.markdown_quote_query
            for nested_id, nested_node in quote_query:iter_captures(info.node, buf) do
                local nested_capture = quote_query.captures[nested_id]
                local nested_info = ts.info(nested_node, buf)
                logger.debug_node_info(nested_capture, nested_info)
                if nested_capture == 'quote_marker' then
                    list.add(marks, M.render_quote_marker(nested_info, info))
                else
                    logger.unhandled_capture('markdown quote', nested_capture)
                end
            end
        elseif capture == 'table' then
            vim.list_extend(marks, M.render_table(buf, info))
        else
            logger.unhandled_capture('markdown', capture)
        end
    end
    return marks
end

---@private
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark[]
M.render_heading = function(buf, info)
    local heading = state.config.heading
    if not heading.enabled then
        return {}
    end
    local marks = {}

    local level = str.width(info.text)
    local foreground = list.clamp(heading.foregrounds, level)
    local icon = list.cycle(heading.icons, level)
    local background = list.clamp(heading.backgrounds, level)

    -- Available width is level + 1 - concealed, where level = number of `#` characters, one
    -- is added to account for the space after the last `#` but before the heading title,
    -- and concealed text is subtracted since that space is not usable
    local padding = level + 1 - ts.concealed(buf, info) - str.width(icon)
    if padding < 0 then
        -- Requires inline extmarks to place when there is not enough space available
        if util.has_10 then
            ---@type render.md.Mark
            local icon_mark = {
                conceal = true,
                start_row = info.start_row,
                start_col = info.start_col,
                opts = {
                    end_row = info.end_row,
                    end_col = info.end_col,
                    virt_text = { { icon, { foreground, background } } },
                    virt_text_pos = 'inline',
                    conceal = '',
                },
            }
            list.add(marks, icon_mark)
        end
    else
        ---@type render.md.Mark
        local icon_mark = {
            conceal = true,
            start_row = info.start_row,
            start_col = info.start_col,
            opts = {
                end_row = info.end_row,
                end_col = info.end_col,
                virt_text = { { str.pad(icon, padding), { foreground, background } } },
                virt_text_pos = 'overlay',
            },
        }
        list.add(marks, icon_mark)
    end
    ---@type render.md.Mark
    local background_mark = {
        conceal = true,
        start_row = info.start_row,
        start_col = 0,
        opts = {
            end_row = info.end_row + 1,
            end_col = 0,
            hl_group = background,
            hl_eol = true,
        },
    }
    list.add(marks, background_mark)
    if heading.sign then
        list.add(marks, M.render_sign(buf, info, list.cycle(heading.signs, level), foreground))
    end

    return marks
end

---@private
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark?
M.render_dash = function(buf, info)
    local dash = state.config.dash
    if not dash.enabled then
        return nil
    end
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = 0,
        opts = {
            virt_text = { { dash.icon:rep(util.get_width(buf)), dash.highlight } },
            virt_text_pos = 'overlay',
        },
    }
end

---@private
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark[]
M.render_code = function(buf, info)
    local code = state.config.code
    if not code.enabled or code.style == 'none' then
        return {}
    end
    local marks = {}
    local code_info = ts.child(buf, info, 'info_string', info.start_row)
    if code_info ~= nil then
        local language_info = ts.child(buf, code_info, 'language', code_info.start_row)
        if language_info ~= nil then
            vim.list_extend(marks, M.render_language(buf, language_info, info))
        end
    end
    if not vim.tbl_contains({ 'normal', 'full' }, code.style) then
        return marks
    end
    local start_row = info.start_row
    local end_row = info.end_row
    -- Do not attempt to render single line code block
    if start_row == end_row - 1 then
        return marks
    end
    if code.border == 'thin' then
        local code_start = ts.child(buf, info, 'fenced_code_block_delimiter', info.start_row)
        if #marks == 0 and ts.hidden(buf, code_info) and ts.hidden(buf, code_start) then
            start_row = start_row + 1
            ---@type render.md.Mark
            local start_mark = {
                conceal = true,
                start_row = info.start_row,
                start_col = info.start_col,
                opts = {
                    virt_text = { { code.above:rep(util.get_width(buf)), colors.inverse(code.highlight) } },
                    virt_text_pos = 'overlay',
                },
            }
            list.add(marks, start_mark)
        end
        local code_end = ts.child(buf, info, 'fenced_code_block_delimiter', info.end_row - 1)
        if ts.hidden(buf, code_end) then
            end_row = end_row - 1
            ---@type render.md.Mark
            local end_mark = {
                conceal = true,
                start_row = info.end_row - 1,
                start_col = info.start_col,
                opts = {
                    virt_text = { { code.below:rep(util.get_width(buf)), colors.inverse(code.highlight) } },
                    virt_text_pos = 'overlay',
                },
            }
            list.add(marks, end_mark)
        end
    end
    ---@type render.md.Mark
    local background_mark = {
        conceal = false,
        start_row = start_row,
        start_col = 0,
        opts = {
            end_row = end_row,
            end_col = 0,
            hl_group = code.highlight,
            hl_eol = true,
        },
    }
    list.add(marks, background_mark)
    -- Requires inline extmarks
    if not util.has_10 or code.left_pad <= 0 then
        return marks
    end
    for row = start_row, end_row - 1 do
        -- Uses a low priority so other marks are loaded first and included in padding
        ---@type render.md.Mark
        local row_padding_mark = {
            conceal = false,
            start_row = row,
            start_col = info.start_col,
            opts = {
                end_row = row + 1,
                priority = 0,
                virt_text = { { str.pad('', code.left_pad), code.highlight } },
                virt_text_pos = 'inline',
            },
        }
        list.add(marks, row_padding_mark)
    end
    return marks
end

---@private
---@param buf integer
---@param info render.md.NodeInfo
---@param code_block render.md.NodeInfo
---@return render.md.Mark[]
M.render_language = function(buf, info, code_block)
    local code = state.config.code
    if not vim.tbl_contains({ 'language', 'full' }, code.style) then
        return {}
    end
    local icon, icon_highlight = icons.get(info.text)
    if icon == nil or icon_highlight == nil then
        return {}
    end
    local marks = {}
    if code.sign then
        list.add(marks, M.render_sign(buf, info, icon, icon_highlight))
    end
    -- Requires inline extmarks
    if not util.has_10 then
        return marks
    end
    local icon_text = icon .. ' '
    if ts.hidden(buf, info) then
        -- Code blocks will pick up varying amounts of leading white space depending on the
        -- context they are in. This gets lumped into the delimiter node and as a result,
        -- after concealing, the extmark will be left shifted. Logic below accounts for this.
        local padding = str.leading_spaces(code_block.text)
        icon_text = str.pad(icon_text .. info.text, padding)
    end
    local highlight = { icon_highlight }
    if code.style == 'full' then
        highlight = { icon_highlight, code.highlight }
    end
    ---@type render.md.Mark
    local language_marker = {
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            virt_text = { { icon_text, highlight } },
            virt_text_pos = 'inline',
        },
    }
    list.add(marks, language_marker)
    return marks
end

---@private
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark?
M.render_list_marker = function(buf, info)
    ---@return boolean
    local function sibling_checkbox()
        if not state.config.checkbox.enabled then
            return false
        end
        if ts.sibling(buf, info, 'task_list_marker_unchecked') ~= nil then
            return true
        end
        if ts.sibling(buf, info, 'task_list_marker_checked') ~= nil then
            return true
        end
        local paragraph = ts.sibling(buf, info, 'paragraph')
        if paragraph == nil then
            return false
        end
        return component.checkbox(paragraph.text, 'starts') ~= nil
    end
    if sibling_checkbox() then
        -- Hide the list marker for checkboxes rather than replacing with a bullet point
        ---@type render.md.Mark
        return {
            conceal = true,
            start_row = info.start_row,
            start_col = info.start_col,
            opts = {
                end_row = info.end_row,
                end_col = info.end_col,
                conceal = '',
            },
        }
    else
        local bullet = state.config.bullet
        if not bullet.enabled then
            return nil
        end
        -- List markers from tree-sitter should have leading spaces removed, however there are known
        -- edge cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
        -- As a result we handle leading spaces here, can remove if this gets fixed upstream
        local leading_spaces = str.leading_spaces(info.text)
        local level = ts.level_in_section(info, 'list')
        local icon = list.cycle(bullet.icons, level)
        ---@type render.md.Mark
        return {
            conceal = true,
            start_row = info.start_row,
            start_col = info.start_col,
            opts = {
                end_row = info.end_row,
                end_col = info.end_col,
                virt_text = { { str.pad(icon, leading_spaces), bullet.highlight } },
                virt_text_pos = 'overlay',
            },
        }
    end
end

---@private
---@param info render.md.NodeInfo
---@param checkbox_state render.md.CheckboxComponent
---@return render.md.Mark?
M.render_checkbox = function(info, checkbox_state)
    local checkbox = state.config.checkbox
    if not checkbox.enabled then
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
            virt_text = { { str.pad_to(info.text, checkbox_state.icon), checkbox_state.highlight } },
            virt_text_pos = 'overlay',
        },
    }
end

---@private
---@param info render.md.NodeInfo
---@param block_quote render.md.NodeInfo
---@return render.md.Mark?
M.render_quote_marker = function(info, block_quote)
    local quote = state.config.quote
    if not quote.enabled then
        return nil
    end
    local highlight = quote.highlight
    local callout = component.callout(block_quote.text, 'contains')
    if callout ~= nil then
        highlight = callout.highlight
    end
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { info.text:gsub('>', quote.icon), highlight } },
            virt_text_pos = 'overlay',
        },
    }
end

---@private
---@param buf integer
---@param info render.md.NodeInfo
---@param text string
---@param highlight string
---@return render.md.Mark?
M.render_sign = function(buf, info, text, highlight)
    local sign = state.config.sign
    if not sign.enabled then
        return nil
    end
    if vim.tbl_contains(sign.exclude.buftypes, util.get_buf(buf, 'buftype')) then
        return nil
    end
    ---@type render.md.Mark
    return {
        conceal = false,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col,
            sign_text = text,
            sign_hl_group = colors.combine(highlight, sign.highlight),
        },
    }
end

---@private
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark[]
M.render_table = function(buf, info)
    local pipe_table = state.config.pipe_table
    if not pipe_table.enabled or pipe_table.style == 'none' then
        return {}
    end
    local marks = {}

    local delim = nil
    local first = nil
    local last = nil
    for row_node in info.node:iter_children() do
        local row = ts.info(row_node, buf)
        if row.type == 'pipe_table_delimiter_row' then
            delim = row
            list.add(marks, M.render_table_delimiter(row))
        elseif row.type == 'pipe_table_header' then
            first = row
            vim.list_extend(marks, M.render_table_row(buf, row, pipe_table.head))
        elseif row.type == 'pipe_table_row' then
            if last == nil or row.start_row > last.start_row then
                last = row
            end
            vim.list_extend(marks, M.render_table_row(buf, row, pipe_table.row))
        else
            logger.unhandled_type('markdown', 'row', row.type)
        end
    end
    if pipe_table.style == 'full' then
        vim.list_extend(marks, M.render_table_full(buf, delim, first, last))
    end

    return marks
end

---@private
---@param row render.md.NodeInfo
---@return render.md.Mark
M.render_table_delimiter = function(row)
    local pipe_table = state.config.pipe_table
    local border = pipe_table.border
    -- Order matters here, in particular handling inner intersections before left & right
    local delimiter = row.text
        :gsub(' ', '-')
        :gsub('%-|%-', border[11] .. border[5] .. border[11])
        :gsub('|%-', border[4] .. border[11])
        :gsub('%-|', border[11] .. border[6])
        :gsub('%-', border[11])
    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = row.start_row,
        start_col = row.start_col,
        opts = {
            end_row = row.end_row,
            end_col = row.end_col,
            virt_text = { { delimiter, pipe_table.head } },
            virt_text_pos = 'overlay',
        },
    }
end

---@private
---@param buf integer
---@param row render.md.NodeInfo
---@param highlight string
---@return render.md.Mark
M.render_table_row = function(buf, row, highlight)
    local pipe_table = state.config.pipe_table
    local marks = {}
    if vim.tbl_contains({ 'raw', 'padded' }, pipe_table.cell) then
        for cell_node in row.node:iter_children() do
            local cell = ts.info(cell_node, buf)
            if cell.type == '|' then
                ---@type render.md.Mark
                local pipe_mark = {
                    conceal = true,
                    start_row = cell.start_row,
                    start_col = cell.start_col,
                    opts = {
                        end_row = cell.end_row,
                        end_col = cell.end_col,
                        virt_text = { { pipe_table.border[10], highlight } },
                        virt_text_pos = 'overlay',
                    },
                }
                list.add(marks, pipe_mark)
            elseif cell.type == 'pipe_table_cell' then
                -- Requires inline extmarks
                if pipe_table.cell == 'padded' and util.has_10 then
                    local offset = M.table_visual_offset(buf, cell)
                    if offset > 0 then
                        ---@type render.md.Mark
                        local padding_mark = {
                            conceal = true,
                            start_row = cell.start_row,
                            start_col = cell.end_col - 1,
                            opts = {
                                virt_text = { { str.pad('', offset), pipe_table.filler } },
                                virt_text_pos = 'inline',
                            },
                        }
                        list.add(marks, padding_mark)
                    end
                end
            else
                logger.unhandled_type('markdown', 'cell', cell.type)
            end
        end
    elseif pipe_table.cell == 'overlay' then
        ---@type render.md.Mark
        local overlay_mark = {
            conceal = true,
            start_row = row.start_row,
            start_col = row.start_col,
            opts = {
                end_row = row.end_row,
                end_col = row.end_col,
                virt_text = { { row.text:gsub('|', pipe_table.border[10]), highlight } },
                virt_text_pos = 'overlay',
            },
        }
        list.add(marks, overlay_mark)
    end
    return marks
end

---@private
---@param buf integer
---@param delim? render.md.NodeInfo
---@param first? render.md.NodeInfo
---@param last? render.md.NodeInfo
---@return render.md.Mark[]
M.render_table_full = function(buf, delim, first, last)
    local pipe_table = state.config.pipe_table
    local border = pipe_table.border
    if delim == nil or first == nil or last == nil then
        return {}
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
        return {}
    end

    local headings = vim.split(delim.text, '|', { plain = true, trimempty = true })
    local lengths = vim.tbl_map(function(cell)
        return border[11]:rep(str.width(cell))
    end, headings)

    local line_above = border[1] .. table.concat(lengths, border[2]) .. border[3]
    ---@type render.md.Mark
    local above_mark = {
        conceal = false,
        start_row = first.start_row,
        start_col = first.start_col,
        opts = {
            virt_lines_above = true,
            virt_lines = { { { line_above, pipe_table.head } } },
        },
    }

    local line_below = border[7] .. table.concat(lengths, border[8]) .. border[9]
    ---@type render.md.Mark
    local below_mark = {
        conceal = false,
        start_row = last.start_row,
        start_col = last.start_col,
        opts = {
            virt_lines_above = false,
            virt_lines = { { { line_below, pipe_table.row } } },
        },
    }

    return { above_mark, below_mark }
end

---@private
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
