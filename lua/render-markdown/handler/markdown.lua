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

---@class render.md.handler.buf.Markdown
---@field private buf integer
---@field private config render.md.BufferConfig
---@field private marks render.md.Mark[]
local Handler = {}
Handler.__index = Handler

---@param buf integer
---@return render.md.handler.buf.Markdown
function Handler.new(buf)
    local self = setmetatable({}, Handler)
    self.buf = buf
    self.config = state.get_config(buf)
    self.marks = {}
    return self
end

---@param root TSNode
---@return render.md.Mark[]
function Handler:parse(root)
    context.get(self.buf):query(root, state.markdown_query, function(capture, node)
        local info = ts.info(node, self.buf)
        logger.debug_node_info(capture, info)
        if capture == 'heading' then
            self:heading(info)
        elseif capture == 'dash' then
            self:dash(info)
        elseif capture == 'code' then
            self:code(info)
        elseif capture == 'list_marker' then
            self:list_marker(info)
        elseif capture == 'checkbox_unchecked' then
            self:checkbox(info, self.config.checkbox.unchecked)
        elseif capture == 'checkbox_checked' then
            self:checkbox(info, self.config.checkbox.checked)
        elseif capture == 'quote' then
            context.get(self.buf):query(info.node, state.markdown_quote_query, function(nested_capture, nested_node)
                local nested_info = ts.info(nested_node, self.buf)
                logger.debug_node_info(nested_capture, nested_info)
                if nested_capture == 'quote_marker' then
                    self:quote_marker(nested_info, info)
                else
                    logger.unhandled_capture('markdown quote', nested_capture)
                end
            end)
        elseif capture == 'table' then
            self:pipe_table(info)
        else
            logger.unhandled_capture('markdown', capture)
        end
    end)
    return self.marks
end

---@private
---@param mark render.md.Mark
function Handler:add(mark)
    logger.debug('mark', mark)
    table.insert(self.marks, mark)
end

---@private
---@param info render.md.NodeInfo
function Handler:heading(info)
    local heading = self.config.heading
    if not heading.enabled then
        return
    end

    local level = str.width(info.text)
    local icon = list.cycle(heading.icons, level)
    local foreground = list.clamp(heading.foregrounds, level)
    local background = list.clamp(heading.backgrounds, level)

    self:add({
        conceal = true,
        start_row = info.start_row,
        start_col = 0,
        opts = {
            end_row = info.end_row + 1,
            end_col = 0,
            hl_group = background,
            hl_eol = heading.width == 'full',
        },
    })

    if heading.sign then
        self:sign(info, list.cycle(heading.signs, level), foreground)
    end

    if icon == nil then
        return
    end
    -- Available width is level + 1 - concealed, where level = number of `#` characters, one
    -- is added to account for the space after the last `#` but before the heading title,
    -- and concealed text is subtracted since that space is not usable
    local padding = level + 1 - ts.concealed(self.buf, info) - str.width(icon)
    if heading.position == 'inline' or padding < 0 then
        -- Requires inline extmarks to place when there is not enough space available
        if util.has_10 then
            self:add({
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
            })
        end
    else
        self:add({
            conceal = true,
            start_row = info.start_row,
            start_col = info.start_col,
            opts = {
                end_row = info.end_row,
                end_col = info.end_col,
                virt_text = { { str.pad(padding, icon), { foreground, background } } },
                virt_text_pos = 'overlay',
            },
        })
    end
end

---@private
---@param info render.md.NodeInfo
function Handler:dash(info)
    local dash = self.config.dash
    if not dash.enabled then
        return
    end

    local width
    if dash.width == 'full' then
        width = context.get(self.buf):get_width()
    else
        ---@type integer
        width = dash.width
    end

    self:add({
        conceal = true,
        start_row = info.start_row,
        start_col = 0,
        opts = {
            virt_text = { { dash.icon:rep(width), dash.highlight } },
            virt_text_pos = 'overlay',
        },
    })
end

---@private
---@param info render.md.NodeInfo
function Handler:code(info)
    local code = self.config.code
    if not code.enabled or code.style == 'none' then
        return
    end
    local code_block = code_block_parser.parse(code, self.buf, info)
    if code_block == nil then
        return
    end

    local add_background = vim.tbl_contains({ 'normal', 'full' }, code.style)
    add_background = add_background and not vim.tbl_contains(code.disable_background, code_block.language)

    local icon_added = self:language(code_block, add_background)
    if add_background then
        self:code_background(code_block, icon_added)
    end
    self:code_left_pad(code_block, add_background)
end

---@private
---@param code_block render.md.parsed.CodeBlock
---@param add_background boolean
---@return boolean
function Handler:language(code_block, add_background)
    local code = self.config.code
    if not vim.tbl_contains({ 'language', 'full' }, code.style) then
        return false
    end
    local info = code_block.language_info
    if info == nil then
        return false
    end
    local icon, icon_highlight = icons.get(info.text)
    if icon == nil or icon_highlight == nil then
        return false
    end
    if code.sign then
        self:sign(info, icon, icon_highlight)
    end
    local highlight = { icon_highlight }
    if add_background then
        table.insert(highlight, code.highlight)
    end
    -- Requires inline extmarks
    if code.position == 'left' and util.has_10 then
        local icon_text = icon .. ' '
        if ts.hidden(self.buf, info) then
            -- Code blocks will pick up varying amounts of leading white space depending on the
            -- context they are in. This gets lumped into the delimiter node and as a result,
            -- after concealing, the extmark will be left shifted. Logic below accounts for this.
            icon_text = str.pad(code_block.leading_spaces, icon_text .. info.text)
        end
        self:add({
            conceal = true,
            start_row = info.start_row,
            start_col = info.start_col,
            opts = {
                virt_text = { { icon_text, highlight } },
                virt_text_pos = 'inline',
            },
        })
        return true
    elseif code.position == 'right' then
        local icon_text = icon .. ' ' .. info.text
        local win_col = code_block.longest_line
        if code.width == 'block' then
            win_col = win_col - str.width(icon_text)
        end
        self:add({
            conceal = true,
            start_row = info.start_row,
            start_col = 0,
            opts = {
                virt_text = { { icon_text, highlight } },
                virt_text_win_col = win_col,
            },
        })
        return true
    else
        return false
    end
end

---@private
---@param code_block render.md.parsed.CodeBlock
---@param icon_added boolean
function Handler:code_background(code_block, icon_added)
    local code = self.config.code

    if code.border == 'thin' then
        local border_width = code_block.width - code_block.col
        if
            not icon_added
            and ts.hidden(self.buf, code_block.code_info)
            and ts.hidden(self.buf, code_block.start_delim)
        then
            self:add({
                conceal = true,
                start_row = code_block.start_row,
                start_col = code_block.col,
                opts = {
                    virt_text = { { code.above:rep(border_width), colors.inverse(code.highlight) } },
                    virt_text_pos = 'overlay',
                },
            })
            code_block.start_row = code_block.start_row + 1
        end
        if ts.hidden(self.buf, code_block.end_delim) then
            self:add({
                conceal = true,
                start_row = code_block.end_row - 1,
                start_col = code_block.col,
                opts = {
                    virt_text = { { code.below:rep(border_width), colors.inverse(code.highlight) } },
                    virt_text_pos = 'overlay',
                },
            })
            code_block.end_row = code_block.end_row - 1
        end
    end

    self:add({
        conceal = false,
        start_row = code_block.start_row,
        start_col = 0,
        opts = {
            end_row = code_block.end_row,
            end_col = 0,
            hl_group = code.highlight,
            hl_eol = true,
        },
    })

    if code.width == 'block' then
        -- Overwrite anything beyond left_pad + block width + right_pad with Normal
        local padding = str.pad(vim.o.columns * 2)
        for row = code_block.start_row, code_block.end_row - 1 do
            self:add({
                conceal = false,
                start_row = row,
                start_col = 0,
                opts = {
                    priority = 0,
                    virt_text = { { padding, 'Normal' } },
                    virt_text_win_col = code_block.width,
                },
            })
        end
    end
end

---@private
---@param code_block render.md.parsed.CodeBlock
---@param add_background boolean
function Handler:code_left_pad(code_block, add_background)
    local code = self.config.code
    -- Requires inline extmarks
    if not util.has_10 or code.left_pad <= 0 then
        return
    end
    local padding = str.pad(code.left_pad)
    local highlight
    if add_background then
        highlight = code.highlight
    else
        highlight = 'Normal'
    end
    for row = code_block.start_row, code_block.end_row - 1 do
        -- Uses a low priority so other marks are loaded first and included in padding
        self:add({
            conceal = false,
            start_row = row,
            start_col = code_block.col,
            opts = {
                end_row = row + 1,
                priority = 0,
                virt_text = { { padding, highlight } },
                virt_text_pos = 'inline',
            },
        })
    end
end

---@private
---@param info render.md.NodeInfo
function Handler:list_marker(info)
    ---@return boolean
    local function sibling_checkbox()
        if not self.config.checkbox.enabled then
            return false
        end
        if ts.sibling(self.buf, info, 'task_list_marker_unchecked') ~= nil then
            return true
        end
        if ts.sibling(self.buf, info, 'task_list_marker_checked') ~= nil then
            return true
        end
        local paragraph = ts.sibling(self.buf, info, 'paragraph')
        if paragraph == nil then
            return false
        end
        return component.checkbox(self.config, paragraph.text, 'starts') ~= nil
    end
    if sibling_checkbox() then
        -- Hide the list marker for checkboxes rather than replacing with a bullet point
        self:add({
            conceal = true,
            start_row = info.start_row,
            start_col = info.start_col,
            opts = {
                end_row = info.end_row,
                end_col = info.end_col,
                conceal = '',
            },
        })
    else
        local bullet = self.config.bullet
        if not bullet.enabled then
            return
        end
        local level = ts.level_in_section(info, 'list')
        local icon = list.cycle(bullet.icons, level)
        if icon == nil then
            return
        end
        -- List markers from tree-sitter should have leading spaces removed, however there are known
        -- edge cases in the parser: https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/127
        -- As a result we handle leading spaces here, can remove if this gets fixed upstream
        local leading_spaces = str.leading_spaces(info.text)
        self:add({
            conceal = true,
            start_row = info.start_row,
            start_col = info.start_col,
            opts = {
                end_row = info.end_row,
                end_col = info.end_col,
                virt_text = { { str.pad(leading_spaces, icon), bullet.highlight } },
                virt_text_pos = 'overlay',
            },
        })
        -- Requires inline extmarks
        if util.has_10 and bullet.right_pad > 0 then
            self:add({
                conceal = true,
                start_row = info.start_row,
                start_col = info.end_col - 1,
                opts = {
                    virt_text = { { str.pad(bullet.right_pad), 'Normal' } },
                    virt_text_pos = 'inline',
                },
            })
        end
    end
end

---@private
---@param info render.md.NodeInfo
---@param checkbox_state render.md.CheckboxComponent
function Handler:checkbox(info, checkbox_state)
    if not self.config.checkbox.enabled then
        return
    end
    self:add({
        conceal = true,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col,
            virt_text = { { str.pad_to(info.text, checkbox_state.icon), checkbox_state.highlight } },
            virt_text_pos = 'overlay',
        },
    })
end

---@private
---@param info render.md.NodeInfo
---@param block_quote render.md.NodeInfo
function Handler:quote_marker(info, block_quote)
    local quote = self.config.quote
    if not quote.enabled then
        return
    end
    local highlight = quote.highlight
    local callout = component.callout(self.config, block_quote.text, 'contains')
    if callout ~= nil then
        highlight = callout.highlight
    end
    self:add({
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
    })
end

---@private
---@param info render.md.NodeInfo
---@param text? string
---@param highlight string
function Handler:sign(info, text, highlight)
    local sign = self.config.sign
    if not sign.enabled or text == nil then
        return
    end
    self:add({
        conceal = false,
        start_row = info.start_row,
        start_col = info.start_col,
        opts = {
            end_row = info.end_row,
            end_col = info.end_col,
            sign_text = text,
            sign_hl_group = colors.combine(highlight, sign.highlight),
        },
    })
end

---@private
---@param info render.md.NodeInfo
function Handler:pipe_table(info)
    local pipe_table = self.config.pipe_table
    if not pipe_table.enabled or pipe_table.style == 'none' then
        return
    end
    local parsed_table = pipe_table_parser.parse(self.buf, info)
    if parsed_table == nil then
        return
    end

    self:table_row(parsed_table.head, pipe_table.head)
    self:table_delimiter(parsed_table.delim, parsed_table.columns)
    for _, row in ipairs(parsed_table.rows) do
        self:table_row(row, pipe_table.row)
    end
    if pipe_table.style == 'full' then
        self:table_full(parsed_table)
    end
end

---@private
---@param row render.md.NodeInfo
---@param columns render.md.parsed.TableColumn[]
function Handler:table_delimiter(row, columns)
    local pipe_table = self.config.pipe_table
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
    self:add({
        conceal = true,
        start_row = row.start_row,
        start_col = row.start_col,
        opts = {
            end_row = row.end_row,
            end_col = row.end_col,
            virt_text = { { delimiter, pipe_table.head } },
            virt_text_pos = 'overlay',
        },
    })
end

---@private
---@param row render.md.NodeInfo
---@param highlight string
function Handler:table_row(row, highlight)
    local pipe_table = self.config.pipe_table
    if vim.tbl_contains({ 'raw', 'padded' }, pipe_table.cell) then
        for cell_node in row.node:iter_children() do
            local cell = ts.info(cell_node, self.buf)
            if cell.type == '|' then
                self:add({
                    conceal = true,
                    start_row = cell.start_row,
                    start_col = cell.start_col,
                    opts = {
                        end_row = cell.end_row,
                        end_col = cell.end_col,
                        virt_text = { { pipe_table.border[10], highlight } },
                        virt_text_pos = 'overlay',
                    },
                })
            elseif cell.type == 'pipe_table_cell' then
                -- Requires inline extmarks
                if pipe_table.cell == 'padded' and util.has_10 then
                    local offset = self:table_visual_offset(cell)
                    if offset > 0 then
                        self:add({
                            conceal = true,
                            start_row = cell.start_row,
                            start_col = cell.end_col - 1,
                            opts = {
                                virt_text = { { str.pad(offset), pipe_table.filler } },
                                virt_text_pos = 'inline',
                            },
                        })
                    end
                end
            else
                logger.unhandled_type('markdown', 'cell', cell.type)
            end
        end
    elseif pipe_table.cell == 'overlay' then
        self:add({
            conceal = true,
            start_row = row.start_row,
            start_col = row.start_col,
            opts = {
                end_row = row.end_row,
                end_col = row.end_col,
                virt_text = { { row.text:gsub('|', pipe_table.border[10]), highlight } },
                virt_text_pos = 'overlay',
            },
        })
    end
end

---@private
---@param parsed_table render.md.parsed.PipeTable
function Handler:table_full(parsed_table)
    local pipe_table = self.config.pipe_table
    local border = pipe_table.border

    ---@param info render.md.NodeInfo
    ---@return integer
    local function width(info)
        local result = str.width(info.text)
        if pipe_table.cell == 'raw' then
            -- For the raw cell style we want the lengths to match after
            -- concealing & inlined elements
            result = result - self:table_visual_offset(info)
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
    self:add({
        conceal = false,
        start_row = first.start_row,
        start_col = first.start_col,
        opts = {
            virt_lines_above = true,
            virt_lines = { { { line_above, pipe_table.head } } },
        },
    })

    local line_below = border[7] .. table.concat(sections, border[8]) .. border[9]
    self:add({
        conceal = false,
        start_row = last.start_row,
        start_col = last.start_col,
        opts = {
            virt_lines_above = false,
            virt_lines = { { { line_below, pipe_table.row } } },
        },
    })
end

---@private
---@param info render.md.NodeInfo
---@return integer
function Handler:table_visual_offset(info)
    local result = ts.concealed(self.buf, info)
    local icon_ranges = context.get(self.buf):get_links(info.start_row)
    for _, icon_range in ipairs(icon_ranges) do
        if info.start_col < icon_range[2] and info.end_col > icon_range[1] then
            result = result - str.width(icon_range[3])
        end
    end
    return result
end

---@class render.md.handler.Markdown: render.md.Handler
local M = {}

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
function M.parse(root, buf)
    return Handler.new(buf):parse(root)
end

return M
