local code_block_parser = require('render-markdown.parser.code_block')
local colors = require('render-markdown.colors')
local component = require('render-markdown.component')
local context = require('render-markdown.context')
local icons = require('render-markdown.icons')
local list = require('render-markdown.list')
local logger = require('render-markdown.logger')
local pipe_table_parser = require('render-markdown.parser.pipe_table')
local state = require('render-markdown.state')
local str = require('render-markdown.str')
local ts = require('render-markdown.ts')
local util = require('render-markdown.util')

---@class render.md.handler.Markdown: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
function M.parse(root, buf)
    local config = state.get_config(buf)
    local marks = {}
    context.get(buf):query(root, state.markdown_query, function(capture, node)
        local info = ts.info(node, buf)
        logger.debug_node_info(capture, info)
        if capture == 'heading' then
            vim.list_extend(marks, M.heading(config, buf, info))
        elseif capture == 'dash' then
            list.add_mark(marks, M.dash(config, buf, info))
        elseif capture == 'code' then
            vim.list_extend(marks, M.code(config, buf, info))
        elseif capture == 'list_marker' then
            vim.list_extend(marks, M.list_marker(config, buf, info))
        elseif capture == 'checkbox_unchecked' then
            list.add_mark(marks, M.checkbox(config, info, config.checkbox.unchecked))
        elseif capture == 'checkbox_checked' then
            list.add_mark(marks, M.checkbox(config, info, config.checkbox.checked))
        elseif capture == 'quote' then
            context.get(buf):query(info.node, state.markdown_quote_query, function(nested_capture, nested_node)
                local nested_info = ts.info(nested_node, buf)
                logger.debug_node_info(nested_capture, nested_info)
                if nested_capture == 'quote_marker' then
                    list.add_mark(marks, M.quote_marker(config, nested_info, info))
                else
                    logger.unhandled_capture('markdown quote', nested_capture)
                end
            end)
        elseif capture == 'table' then
            vim.list_extend(marks, M.pipe_table(config, buf, info))
        else
            logger.unhandled_capture('markdown', capture)
        end
    end)
    return marks
end

---@private
---@param config render.md.BufferConfig
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark[]
function M.heading(config, buf, info)
    local heading = config.heading
    if not heading.enabled then
        return {}
    end
    local marks = {}

    local level = str.width(info.text)
    local icon = list.cycle(heading.icons, level)
    local foreground = list.clamp(heading.foregrounds, level)
    local background = list.clamp(heading.backgrounds, level)

    ---@type render.md.Mark
    local background_mark = {
        conceal = true,
        start_row = info.start_row,
        start_col = 0,
        opts = {
            end_row = info.end_row + 1,
            end_col = 0,
            hl_group = background,
            hl_eol = heading.width == 'full',
        },
    }
    list.add_mark(marks, background_mark)

    if heading.sign then
        list.add_mark(marks, M.sign(config, info, list.cycle(heading.signs, level), foreground))
    end

    if icon == nil then
        return marks
    end
    -- Available width is level + 1 - concealed, where level = number of `#` characters, one
    -- is added to account for the space after the last `#` but before the heading title,
    -- and concealed text is subtracted since that space is not usable
    local padding = level + 1 - ts.concealed(buf, info) - str.width(icon)
    if heading.position == 'inline' or padding < 0 then
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
            list.add_mark(marks, icon_mark)
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
                virt_text = { { str.pad(padding, icon), { foreground, background } } },
                virt_text_pos = 'overlay',
            },
        }
        list.add_mark(marks, icon_mark)
    end
    return marks
end

---@private
---@param config render.md.BufferConfig
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark?
function M.dash(config, buf, info)
    local dash = config.dash
    if not dash.enabled then
        return nil
    end

    local width
    if dash.width == 'full' then
        width = context.get(buf):get_width()
    else
        ---@type integer
        width = dash.width
    end

    ---@type render.md.Mark
    return {
        conceal = true,
        start_row = info.start_row,
        start_col = 0,
        opts = {
            virt_text = { { dash.icon:rep(width), dash.highlight } },
            virt_text_pos = 'overlay',
        },
    }
end

---@private
---@param config render.md.BufferConfig
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark[]
function M.code(config, buf, info)
    local code = config.code
    if not code.enabled or code.style == 'none' then
        return {}
    end
    local code_block = code_block_parser.parse(code, buf, info)
    if code_block == nil then
        return {}
    end

    local add_background = vim.tbl_contains({ 'normal', 'full' }, code.style)
    add_background = add_background and not vim.tbl_contains(code.disable_background, code_block.language)

    local marks, icon_added = M.language(config, buf, code_block, add_background)
    if add_background then
        vim.list_extend(marks, M.code_background(config, buf, code_block, icon_added))
    end
    vim.list_extend(marks, M.code_left_pad(config, code_block, add_background))
    return marks
end

---@private
---@param config render.md.BufferConfig
---@param buf integer
---@param code_block render.md.parsed.CodeBlock
---@param add_background boolean
---@return render.md.Mark[], boolean
function M.language(config, buf, code_block, add_background)
    local code = config.code
    if not vim.tbl_contains({ 'language', 'full' }, code.style) then
        return {}, false
    end
    local info = code_block.language_info
    if info == nil then
        return {}, false
    end
    local icon, icon_highlight = icons.get(info.text)
    if icon == nil or icon_highlight == nil then
        return {}, false
    end
    local marks = {}
    if code.sign then
        list.add_mark(marks, M.sign(config, info, icon, icon_highlight))
    end
    local highlight = { icon_highlight }
    if add_background then
        table.insert(highlight, code.highlight)
    end
    -- Requires inline extmarks
    if code.position == 'left' and util.has_10 then
        local icon_text = icon .. ' '
        if ts.hidden(buf, info) then
            -- Code blocks will pick up varying amounts of leading white space depending on the
            -- context they are in. This gets lumped into the delimiter node and as a result,
            -- after concealing, the extmark will be left shifted. Logic below accounts for this.
            icon_text = str.pad(code_block.leading_spaces, icon_text .. info.text)
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
        list.add_mark(marks, language_marker)
        return marks, true
    elseif code.position == 'right' then
        local icon_text = icon .. ' ' .. info.text
        local win_col = code_block.longest_line
        if code.width == 'block' then
            win_col = win_col - str.width(icon_text)
        end
        ---@type render.md.Mark
        local language_marker = {
            conceal = true,
            start_row = info.start_row,
            start_col = 0,
            opts = {
                virt_text = { { icon_text, highlight } },
                virt_text_win_col = win_col,
            },
        }
        list.add_mark(marks, language_marker)
        return marks, true
    else
        return marks, false
    end
end

---@private
---@param config render.md.BufferConfig
---@param buf integer
---@param code_block render.md.parsed.CodeBlock
---@param icon_added boolean
---@return render.md.Mark[]
function M.code_background(config, buf, code_block, icon_added)
    local code = config.code

    local marks = {}
    if code.border == 'thin' then
        local border_width = code_block.width - code_block.col
        if not icon_added and ts.hidden(buf, code_block.code_info) and ts.hidden(buf, code_block.start_delim) then
            ---@type render.md.Mark
            local start_mark = {
                conceal = true,
                start_row = code_block.start_row,
                start_col = code_block.col,
                opts = {
                    virt_text = { { code.above:rep(border_width), colors.inverse(code.highlight) } },
                    virt_text_pos = 'overlay',
                },
            }
            list.add_mark(marks, start_mark)
            code_block.start_row = code_block.start_row + 1
        end
        if ts.hidden(buf, code_block.end_delim) then
            ---@type render.md.Mark
            local end_mark = {
                conceal = true,
                start_row = code_block.end_row - 1,
                start_col = code_block.col,
                opts = {
                    virt_text = { { code.below:rep(border_width), colors.inverse(code.highlight) } },
                    virt_text_pos = 'overlay',
                },
            }
            list.add_mark(marks, end_mark)
            code_block.end_row = code_block.end_row - 1
        end
    end

    ---@type render.md.Mark
    local background_mark = {
        conceal = false,
        start_row = code_block.start_row,
        start_col = 0,
        opts = {
            end_row = code_block.end_row,
            end_col = 0,
            hl_group = code.highlight,
            hl_eol = true,
        },
    }
    list.add_mark(marks, background_mark)

    if code.width == 'block' then
        -- Overwrite anything beyond left_pad + block width + right_pad with Normal
        local padding = str.pad(vim.o.columns * 2)
        for row = code_block.start_row, code_block.end_row - 1 do
            ---@type render.md.Mark
            local block_background_mark = {
                conceal = false,
                start_row = row,
                start_col = 0,
                opts = {
                    priority = 0,
                    virt_text = { { padding, 'Normal' } },
                    virt_text_win_col = code_block.width,
                },
            }
            list.add_mark(marks, block_background_mark)
        end
    end
    return marks
end

---@private
---@param config render.md.BufferConfig
---@param code_block render.md.parsed.CodeBlock
---@param add_background boolean
---@return render.md.Mark[]
function M.code_left_pad(config, code_block, add_background)
    local code = config.code
    -- Requires inline extmarks
    if not util.has_10 or code.left_pad <= 0 then
        return {}
    end
    local marks = {}
    local padding = str.pad(code.left_pad)
    local highlight
    if add_background then
        highlight = code.highlight
    else
        highlight = 'Normal'
    end
    for row = code_block.start_row, code_block.end_row - 1 do
        -- Uses a low priority so other marks are loaded first and included in padding
        ---@type render.md.Mark
        local padding_mark = {
            conceal = false,
            start_row = row,
            start_col = code_block.col,
            opts = {
                end_row = row + 1,
                priority = 0,
                virt_text = { { padding, highlight } },
                virt_text_pos = 'inline',
            },
        }
        list.add_mark(marks, padding_mark)
    end
    return marks
end

---@private
---@param config render.md.BufferConfig
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark[]
function M.list_marker(config, buf, info)
    ---@return boolean
    local function sibling_checkbox()
        if not config.checkbox.enabled then
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
        return component.checkbox(config, paragraph.text, 'starts') ~= nil
    end
    if sibling_checkbox() then
        -- Hide the list marker for checkboxes rather than replacing with a bullet point
        ---@type render.md.Mark
        local checkbox_mark = {
            conceal = true,
            start_row = info.start_row,
            start_col = info.start_col,
            opts = {
                end_row = info.end_row,
                end_col = info.end_col,
                conceal = '',
            },
        }
        return { checkbox_mark }
    else
        local bullet = config.bullet
        if not bullet.enabled then
            return {}
        end
        local level = ts.level_in_section(info, 'list')
        local icon = list.cycle(bullet.icons, level)
        if icon == nil then
            return {}
        end
        local marks = {}
        -- List markers from tree-sitter should have leading spaces removed, however there are known
        -- edge cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
        -- As a result we handle leading spaces here, can remove if this gets fixed upstream
        local leading_spaces = str.leading_spaces(info.text)
        ---@type render.md.Mark
        local bullet_mark = {
            conceal = true,
            start_row = info.start_row,
            start_col = info.start_col,
            opts = {
                end_row = info.end_row,
                end_col = info.end_col,
                virt_text = { { str.pad(leading_spaces, icon), bullet.highlight } },
                virt_text_pos = 'overlay',
            },
        }
        list.add_mark(marks, bullet_mark)
        -- Requires inline extmarks
        if util.has_10 and bullet.right_pad > 0 then
            ---@type render.md.Mark
            local padding_mark = {
                conceal = true,
                start_row = info.start_row,
                start_col = info.end_col - 1,
                opts = {
                    virt_text = { { str.pad(bullet.right_pad), 'Normal' } },
                    virt_text_pos = 'inline',
                },
            }
            list.add_mark(marks, padding_mark)
        end
        return marks
    end
end

---@private
---@param config render.md.BufferConfig
---@param info render.md.NodeInfo
---@param checkbox_state render.md.CheckboxComponent
---@return render.md.Mark?
function M.checkbox(config, info, checkbox_state)
    local checkbox = config.checkbox
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
---@param config render.md.BufferConfig
---@param info render.md.NodeInfo
---@param block_quote render.md.NodeInfo
---@return render.md.Mark?
function M.quote_marker(config, info, block_quote)
    local quote = config.quote
    if not quote.enabled then
        return nil
    end
    local highlight = quote.highlight
    local callout = component.callout(config, block_quote.text, 'contains')
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
            virt_text_repeat_linebreak = quote.repeat_linebreak or nil,
        },
    }
end

---@private
---@param config render.md.BufferConfig
---@param info render.md.NodeInfo
---@param text? string
---@param highlight string
---@return render.md.Mark?
function M.sign(config, info, text, highlight)
    local sign = config.sign
    if not sign.enabled or text == nil then
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
---@param config render.md.BufferConfig
---@param buf integer
---@param info render.md.NodeInfo
---@return render.md.Mark[]
function M.pipe_table(config, buf, info)
    local pipe_table = config.pipe_table
    if not pipe_table.enabled or pipe_table.style == 'none' then
        return {}
    end
    local parsed_table = pipe_table_parser.parse(buf, info)
    if parsed_table == nil then
        return {}
    end

    local marks = {}
    vim.list_extend(marks, M.table_row(config, buf, parsed_table.head, pipe_table.head))
    list.add_mark(marks, M.table_delimiter(config, parsed_table.delim, parsed_table.columns))
    for _, row in ipairs(parsed_table.rows) do
        vim.list_extend(marks, M.table_row(config, buf, row, pipe_table.row))
    end
    if pipe_table.style == 'full' then
        vim.list_extend(marks, M.table_full(config, buf, parsed_table))
    end
    return marks
end

---@private
---@param config render.md.BufferConfig
---@param row render.md.NodeInfo
---@param columns render.md.parsed.TableColumn[]
---@return render.md.Mark
function M.table_delimiter(config, row, columns)
    local pipe_table = config.pipe_table
    local indicator = pipe_table.alignment_indicator
    local border = pipe_table.border
    local sections = vim.tbl_map(
        ---@param column render.md.parsed.TableColumn
        ---@return string
        function(column)
            -- If column is small there's no good place to put the alignment indicator
            -- Alignment indicator must be exactly one character wide
            -- We do not put an indicator for default alignment
            if column.width < 4 or str.width(indicator) ~= 1 or column.alignment == 'default' then
                return border[11]:rep(column.width)
            end
            -- Handle the various alignmnet possibilities
            local left = border[11]:rep(math.floor(column.width / 2))
            local right = border[11]:rep(math.ceil(column.width / 2) - 1)
            if column.alignment == 'left' then
                return indicator .. left .. right
            elseif column.alignment == 'right' then
                return left .. right .. indicator
            else
                return left .. indicator .. right
            end
        end,
        columns
    )
    local delimiter = border[4] .. table.concat(sections, border[5]) .. border[6]
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
---@param config render.md.BufferConfig
---@param buf integer
---@param row render.md.NodeInfo
---@param highlight string
---@return render.md.Mark
function M.table_row(config, buf, row, highlight)
    local pipe_table = config.pipe_table
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
                list.add_mark(marks, pipe_mark)
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
                                virt_text = { { str.pad(offset), pipe_table.filler } },
                                virt_text_pos = 'inline',
                            },
                        }
                        list.add_mark(marks, padding_mark)
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
        list.add_mark(marks, overlay_mark)
    end
    return marks
end

---@private
---@param config render.md.BufferConfig
---@param buf integer
---@param parsed_table render.md.parsed.PipeTable
---@return render.md.Mark[]
function M.table_full(config, buf, parsed_table)
    local pipe_table = config.pipe_table
    local border = pipe_table.border

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

    local first = parsed_table.head
    local last = parsed_table.rows[#parsed_table.rows]

    -- Do not need to account for concealed / inlined text on delimiter row
    local delim_width = str.width(parsed_table.delim.text)
    if delim_width ~= width(first) or delim_width ~= width(last) then
        return {}
    end

    local sections = vim.tbl_map(
        ---@param column render.md.parsed.TableColumn
        ---@return string
        function(column)
            return border[11]:rep(column.width)
        end,
        parsed_table.columns
    )

    local line_above = border[1] .. table.concat(sections, border[2]) .. border[3]
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

    local line_below = border[7] .. table.concat(sections, border[8]) .. border[9]
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
function M.table_visual_offset(buf, info)
    local result = ts.concealed(buf, info)
    local icon_ranges = context.get(buf):get_links(info.start_row)
    for _, icon_range in ipairs(icon_ranges) do
        if info.start_col < icon_range[2] and info.end_col > icon_range[1] then
            result = result - str.width(icon_range[3])
        end
    end
    return result
end

return M
