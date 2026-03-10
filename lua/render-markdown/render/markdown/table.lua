local Base = require('render-markdown.render.base')
local Line = require('render-markdown.lib.line')
local env = require('render-markdown.lib.env')
local iter = require('render-markdown.lib.iter')
local log = require('render-markdown.core.log')
local str = require('render-markdown.lib.str')

---@class render.md.table.Data
---@field delim render.md.Node
---@field cols render.md.table.Col[]
---@field rows render.md.table.Row[]

---@class render.md.table.Col
---@field width integer
---@field alignment render.md.table.col.Alignment

---@enum render.md.table.col.Alignment
local Alignment = {
    left = 'left',
    right = 'right',
    center = 'center',
    default = 'default',
}

---@class render.md.table.Row
---@field node render.md.Node
---@field pipes render.md.Node[]
---@field cells render.md.table.row.Cell[]

---@class render.md.table.row.Cell
---@field node render.md.Node
---@field width integer
---@field space render.md.table.cell.Space

---@class render.md.table.cell.Space
---@field left integer
---@field right integer

---@class render.md.table.row.Parts
---@field pipes render.md.Node[]
---@field cells render.md.Node[]

---@class render.md.table.Layout
---@field wrap boolean
---@field col_widths integer[]
---@field row_heights integer[]

---@class render.md.render.Table: render.md.Render
---@field private config render.md.table.Config
---@field private data render.md.table.Data
---@field private layout render.md.table.Layout
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.pipe_table
    if not self.config.enabled then
        return false
    end

    -- ensure delimiter and rows exist
    local delim = nil ---@type render.md.Node?
    local row_nodes = {} ---@type render.md.Node[]
    local types = {
        delim = 'pipe_table_delimiter_row',
        row = { 'pipe_table_header', 'pipe_table_row' },
        skip = { 'block_continuation' },
    }
    self.node:for_each_child(function(node)
        if node.type == types.delim then
            delim = node
        elseif self.context.view:overlaps(node:get()) then
            if vim.tbl_contains(types.row, node.type) then
                row_nodes[#row_nodes + 1] = node
            elseif not vim.tbl_contains(types.skip, node.type) then
                log.unhandled(self.context.buf, 'markdown', 'row', node.type)
            end
        end
    end)
    if not delim or #row_nodes == 0 then
        return false
    end

    local cols = self:parse_cols(delim)
    if not cols then
        return false
    end

    local rows = {} ---@type render.md.table.Row[]
    table.sort(row_nodes)
    for _, row_node in ipairs(row_nodes) do
        local row = self:parse_row(row_node, #cols)
        if row then
            rows[#rows + 1] = row
        end
    end
    if #rows == 0 then
        return false
    end

    -- store the max width in cols
    for _, row in ipairs(rows) do
        for i, cell in ipairs(row.cells) do
            local space = cell.space.left + cell.space.right
            local available = space - (2 * self.config.padding)
            -- if we don't have enough space for padding add it to the width
            local width = cell.width
            if available < 0 then
                width = width - available
            end
            if self.config.cell == 'trimmed' then
                width = width - math.max(available, 0)
            end
            cols[i].width = math.max(cols[i].width, width)
        end
    end

    self.data = { delim = delim, cols = cols, rows = rows }
    self.layout = self:compute_layout()

    -- When wrapping, update delim col widths so delimiter/border rendering
    -- uses the capped widths (padding is included in delim col width).
    if self.layout.wrap then
        for i, w in ipairs(self.layout.col_widths) do
            self.data.delim.cols[i].width = w + 2 * self.config.padding
        end
    end

    return true
end

---@private
---@return render.md.table.Layout
function Render:compute_layout()
    local no_wrap = { wrap = false, col_widths = {}, row_heights = {} }

    -- Feature disabled when max_table_width is 0 (unset)
    if self.config.max_table_width == 0 then
        return no_wrap
    end
    -- Feature disabled when the window has line-wrap turned off — the table will
    -- scroll horizontally so there are no continuation screen lines to fill, and
    -- the col-redistribution logic would make things narrower for no reason.
    if not env.win.get(self.context.win, 'wrap') then
        return no_wrap
    end
    -- Only supported for padded/trimmed cell modes
    if not vim.tbl_contains({ 'padded', 'trimmed' }, self.config.cell) then
        return no_wrap
    end

    local win_width = env.win.width(self.context.win)
    local mtw = self.config.max_table_width
    local available
    if mtw < 0 then
        -- Negative: characters from right edge
        available = win_width + mtw
    elseif mtw <= 1 then
        -- Fraction of window width
        available = math.floor(win_width * mtw)
    else
        -- Absolute character width
        available = math.floor(mtw)
    end
    local num_cols = #self.data.delim.cols
    local padding = self.config.padding

    -- Total table display width = (num_cols+1) pipes + num_cols*(2*padding + text_width)
    -- => text budget = available - (num_cols+1) - num_cols*2*padding
    local overhead = (num_cols + 1) + (num_cols * 2 * padding)
    local text_budget = available - overhead

    -- Collect the natural text-area width for each column (max content width across all rows)
    local max_content = {} ---@type integer[]
    for i = 1, num_cols do
        max_content[i] = math.max(
            self.data.delim.cols[i].width - 2 * padding,
            self.config.min_width
        )
    end
    for _, row in ipairs(self.data.rows) do
        for i, col in ipairs(row.cols) do
            max_content[i] = math.max(max_content[i], col.width)
        end
    end

    -- Iterative redistribution:
    -- Start with an equal share per column. Any column whose content fits
    -- within that share gets locked at its natural width, freeing up budget
    -- for the remaining columns. Repeat until stable.
    local col_widths = {} ---@type integer[]
    local locked = {} ---@type boolean[]
    local locked_total = 0
    local locked_count = 0

    local share = math.floor(text_budget / num_cols)
    local changed = true
    while changed do
        changed = false
        for i = 1, num_cols do
            if not locked[i] and max_content[i] <= share then
                locked[i] = true
                locked_total = locked_total + max_content[i]
                locked_count = locked_count + 1
                changed = true
            end
        end
        if changed then
            local free = num_cols - locked_count
            if free > 0 then
                share = math.floor((text_budget - locked_total) / free)
            end
        end
    end

    -- Assign final widths: locked columns get their natural width, others get the share
    for i = 1, num_cols do
        col_widths[i] = locked[i] and max_content[i] or math.max(share, 1)
    end

    -- Compute per-row heights based on how many lines each cell needs.
    -- Also account for the raw (unrendered) buffer line wrapping: if the source
    -- text is longer than the rendered text (e.g. a long concealed URL), the
    -- buffer line may wrap onto more screen lines than the rendered content
    -- requires.  We must cover all of those screen lines with overlay marks,
    -- so the effective height is max(rendered_lines, raw_screen_lines).
    local row_heights = {} ---@type integer[]
    local needs_wrap = false
    for r, row in ipairs(self.data.rows) do
        local max_lines = 1
        for i, col in ipairs(row.cols) do
            local w = col_widths[i]
            if w > 0 and col.width > w then
                local lines = math.ceil(col.width / w)
                if lines > max_lines then
                    max_lines = lines
                end
                needs_wrap = true
            end
        end
        -- Raw buffer line screen-wrap: ceil(display_width_of_source / win_width)
        local buf_line = vim.api.nvim_buf_get_lines(
            self.context.buf, row.node.start_row, row.node.start_row + 1, false
        )[1] or ''
        local raw_screen_lines = math.max(1, math.ceil(str.width(buf_line) / win_width))
        if raw_screen_lines > max_lines then
            max_lines = raw_screen_lines
            needs_wrap = true
        end
        row_heights[r] = max_lines
    end

    if not needs_wrap then
        return no_wrap
    end

    return { wrap = true, col_widths = col_widths, row_heights = row_heights }
end

---@private
---@param node render.md.Node
---@return render.md.table.Col[]?
function Render:parse_cols(node)
    local parts = self:parse_row_parts(node, 'pipe_table_delimiter_cell')
    if not parts then
        return nil
    end
    local cols = {} ---@type render.md.table.Col[]
    for i, cell in ipairs(parts.cells) do
        local start_col = parts.pipes[i].end_col
        local end_col = parts.pipes[i + 1].start_col
        local width = end_col - start_col
        assert(width >= 0, 'invalid table layout')
        if self.config.cell == 'padded' then
            width = math.max(width, self.config.min_width)
        elseif self.config.cell == 'trimmed' then
            width = self.config.min_width
        end
        cols[#cols + 1] = {
            width = width,
            alignment = Render.alignment(cell),
        }
    end
    return cols
end

---@private
---@param node render.md.Node
---@return render.md.table.col.Alignment
function Render.alignment(node)
    local left = node:child('pipe_table_align_left')
    local right = node:child('pipe_table_align_right')
    if left and right then
        return Alignment.center
    elseif left then
        return Alignment.left
    elseif right then
        return Alignment.right
    else
        return Alignment.default
    end
end


---Compute display segments for a cell: raw text − concealed + injected,
---with treesitter highlight groups preserved.
---@private
---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.mark.Line
function Render:cell_segments(row, start_col, end_col)
    local raw_full = vim.api.nvim_buf_get_text(
        self.context.buf, row, start_col, row, end_col, {}
    )[1] or ''
    -- Trim cell padding upfront so we don't need post-processing
    local lead = #(raw_full:match('^(%s*)') or '')
    local trail = #(raw_full:match('(%s*)$') or '')
    local raw = raw_full:sub(lead + 1, #raw_full - trail)
    local base_col = start_col + lead
    local injections = self.context.offset:range(row, start_col, end_col)

    local segments = {} ---@type render.md.mark.Line
    local function push(text, hl)
        if #text == 0 then return end
        if #segments > 0 and segments[#segments][2] == hl then
            segments[#segments][1] = segments[#segments][1] .. text
        else
            segments[#segments + 1] = { text, hl }
        end
    end

    local function push_injection(inj)
        for _, seg in ipairs(inj.virt_text) do
            push(seg[1], seg[2] or '')
        end
    end

    local inj_i = 1
    -- Flush injections anchored in leading whitespace
    while inj_i <= #injections and injections[inj_i].col < base_col do
        push_injection(injections[inj_i])
        inj_i = inj_i + 1
    end
    local bytes = vim.str_utf_pos(raw)
    for k, start_byte in ipairs(bytes) do
        local end_byte = k < #bytes and bytes[k + 1] - 1 or #raw
        local abs_col = base_col + start_byte - 1
        -- Insert any injections anchored at this byte position
        while inj_i <= #injections and injections[inj_i].col == abs_col do
            push_injection(injections[inj_i])
            inj_i = inj_i + 1
        end
        local char = raw:sub(start_byte, end_byte)
        local body = {
            start_row = row, start_col = abs_col,
            end_col = abs_col + end_byte - start_byte + 1, text = char,
        }
        if self.context.conceal:get(body) <= 0 then
            -- Use built-in API to get the treesitter highlight at this position
            local hl = ''
            for _, cap in ipairs(vim.treesitter.get_captures_at_pos(self.context.buf, row, abs_col)) do
                if cap.lang == 'markdown_inline' and not vim.startswith(cap.capture, 'conceal') then
                    hl = '@' .. cap.capture
                end
            end
            push(char, hl)
        end
    end
    -- Trailing injections after the last character
    while inj_i <= #injections do
        push_injection(injections[inj_i])
        inj_i = inj_i + 1
    end
    return segments
end

--TODO: Critical piece of code
---@private
---@param node render.md.Node
---@param num_cols integer
---@return render.md.table.Row?
function Render:parse_row(node, num_cols)
    local parts = self:parse_row_parts(node, 'pipe_table_cell')
    if not parts or #parts.cells ~= num_cols then
        return nil
    end
    local cells = {} ---@type render.md.table.row.Cell[]
    for i, cell in ipairs(parts.cells) do
        -- account for double width glyphs by replacing cell range with width
        local start_col = parts.pipes[i].end_col
        local end_col = parts.pipes[i + 1].start_col
        local width = (end_col - start_col)
            - (cell.end_col - cell.start_col)
            + self.context:width(cell)
            + self.config.cell_offset({ node = cell:get() })
        assert(width >= 0, 'invalid table layout')
        cells[#cells + 1] = {
            node = cell,
            width = width,
            space = {
                -- gap between the cell start and the pipe start
                left = math.max(cell.start_col - start_col, 0),
                -- attached to the end of the cell itself
                right = math.max(str.spaces('end', cell.text), 0),
            },
        }
    end
    ---@type render.md.table.Row
    return { node = node, pipes = parts.pipes, cells = cells }
end

---@private
---@param node render.md.Node
---@param cell_type string
---@return render.md.table.row.Parts?
function Render:parse_row_parts(node, cell_type)
    local pipes = {} ---@type render.md.Node[]
    local cells = {} ---@type render.md.Node[]
    node:for_each_child(function(child)
        if child.type == '|' then
            pipes[#pipes + 1] = child
        elseif child.type == cell_type then
            cells[#cells + 1] = child
        else
            log.unhandled(self.context.buf, 'markdown', 'cell', child.type)
        end
    end)
    if #pipes == 0 or #cells == 0 or #pipes ~= #cells + 1 then
        return nil
    end
    table.sort(pipes)
    table.sort(cells)
    ---@type render.md.table.row.Parts
    return { pipes = pipes, cells = cells }
end

---@protected
function Render:run()
    self:delimiter()
    if self.layout.wrap then
        for r, row in ipairs(self.data.rows) do
            self:row_wrapped(row, r)
        end
    else
        for _, row in ipairs(self.data.rows) do
            self:row(row)
        end
    end
    if self.config.border_enabled then
        self:border()
    end
end

---@private
function Render:delimiter()
    local delim = self.data.delim
    local border = self.config.border
    local indicator = self.config.alignment_indicator

    local icon = border[11]
    local parts = iter.list.map(self.data.cols, function(col)
        -- must have enough space to put the alignment indicator
        -- alignment indicator must be exactly one character wide
        -- do not put an indicator for default alignment
        local add_indicator = col.width >= 3
            and str.width(indicator) == 1
            and col.alignment ~= Alignment.default
        if not add_indicator then
            return icon:rep(col.width)
        end
        if col.alignment == Alignment.left then
            return indicator .. icon:rep(col.width - 1)
        elseif col.alignment == Alignment.right then
            return icon:rep(col.width - 1) .. indicator
        else
            return indicator .. icon:rep(col.width - 2) .. indicator
        end
    end)
    local delimiter = border[4] .. table.concat(parts, border[5]) .. border[6]

    local line = self:line()
    line:pad(str.spaces('start', delim.text))
    line:text(delimiter, self.config.head)
    line:pad(str.width(delim.text) - line:width())
    self.marks:over(self.config, 'table_border', delim, {
        virt_text = line:get(),
        virt_text_pos = 'overlay',
    })
end

---@private
---@param row render.md.table.Row
function Render:row(row)
    local icon = self.config.border[10]
    local header = row.node.type == 'pipe_table_header'
    local highlight = header and self.config.head or self.config.row

    if vim.tbl_contains({ 'trimmed', 'padded', 'raw' }, self.config.cell) then
        for _, pipe in ipairs(row.pipes) do
            self.marks:over(self.config, 'table_border', pipe, {
                virt_text = { { icon, highlight } },
                virt_text_pos = 'overlay',
            })
        end
    end

    if vim.tbl_contains({ 'trimmed', 'padded' }, self.config.cell) then
        for i, cell in ipairs(row.cells) do
            local col = self.data.cols[i]
            local node = cell.node
            local space = cell.space
            local fill = col.width - cell.width
            -- delim(20) : --------------------
            -- col(4,7,2): ----XXXXXXX--
            -- fill(7)   :              _______
            if not self.context.conceal:enabled() then
                -- result: ----XXXXXXX--_______
                -- without concealing it is impossible to do full alignment
                self:shift(node, 'right', fill)
            elseif col.alignment == Alignment.center then
                -- (7 + 2 - 4) // 2 = 5 // 2 = 2 -> move two spaces to the right
                -- result: __----XXXXXXX--_____
                local shift = math.floor((fill + space.right - space.left) / 2)
                self:shift(node, 'left', shift)
                self:shift(node, 'right', fill - shift)
            elseif col.alignment == Alignment.right then
                -- 2 - 1 = 1 -> conceal one space on right side
                -- result: -_______----XXXXXXX-
                local shift = space.right - self.config.padding
                self:shift(node, 'left', fill + shift)
                self:shift(node, 'right', -shift)
            else
                -- 4 - 1 = 3 -> conceal three spaces on left side
                -- result: -XXXXXXX--_______---
                local shift = space.left - self.config.padding
                self:shift(node, 'left', -shift)
                self:shift(node, 'right', fill + shift)
            end
        end
    elseif self.config.cell == 'overlay' then
        self.marks:over(self.config, 'table_border', row.node, {
            virt_text = { { row.node.text:gsub('|', icon), highlight } },
            virt_text_pos = 'overlay',
        })
    end
end

---@private
---@param row render.md.table.Row
---@param row_index integer
function Render:row_wrapped(row, row_index)
    local height = self.layout.row_heights[row_index]
    local header = row.node.type == 'pipe_table_header'
    local highlight = header and self.config.head or self.config.row
    local border_icon = self.config.border[10]
    local padding = self.config.padding
    local spaces = math.max(str.spaces('start', row.node.text), row.node.start_col)

    -- Pre-compute display segments for each cell in this row
    local cell_segs = {} ---@type render.md.mark.Line[]
    for i, col in ipairs(row.cols) do
        cell_segs[i] = self:cell_segments(col.row, col.start_col, col.end_col)
    end

    local filler = self.config.filler
    local function build_line(visual_line)
        local line = self:line()
        line:pad(spaces, filler)
        for i, _ in ipairs(self.data.delim.cols) do
            local col_width = self.layout.col_widths[i]
            line:text(border_icon, highlight)
            line:pad(padding, filler)
            local cell_line = Line.new(filler)
            vim.list_extend(cell_line:get(), cell_segs[i] or {})
            local chunk = cell_line:sub(visual_line * col_width + 1, (visual_line + 1) * col_width)
            line:extend(chunk)
            line:pad(col_width - chunk:width(), filler)
            line:pad(padding, filler)
        end
        line:text(border_icon, highlight)
        return line
    end

    local buf_line = vim.api.nvim_buf_get_lines(
        self.context.buf, row.node.start_row, row.node.start_row + 1, false
    )[1] or ''
    local win_width = env.win.width(self.context.win)
    local buf_screen_lines = math.max(1, math.ceil(str.width(buf_line) / win_width))

    -- Line 0: conceal the source line then overlay the rendered row on top.
    if #buf_line > 0 then
        self.marks:add(self.config, 'table_border', row.node.start_row, 0, {
            end_row = row.node.start_row,
            end_col = #buf_line,
            conceal = '',
        })
    end
    local first_line = build_line(0)
    self.marks:add(self.config, 'table_border', row.node.start_row, 0, {
        virt_text = first_line:get(),
        virt_text_pos = 'overlay',
        hl_mode = 'combine',
    })

    -- Lines 1..height-1: overlay buffer wrap continuations, then virt_lines.
    local virt_lines = {} ---@type render.md.mark.Line[]
    for vl = 1, height - 1 do
        if vl < buf_screen_lines then
            local byte_col = vim.fn.byteidx(buf_line, vl * win_width)
            if byte_col < 0 then byte_col = #buf_line end
            if #virt_lines > 0 then
                self.marks:add(self.config, 'virtual_lines', row.node.start_row, 0, {
                    virt_lines = virt_lines,
                    virt_lines_above = false,
                })
                virt_lines = {}
            end
            self.marks:add(self.config, 'table_border', row.node.start_row, byte_col, {
                virt_text = build_line(vl):get(),
                virt_text_pos = 'overlay',
                hl_mode = 'combine',
            })
        else
            local vline = self:indent():line(true):extend(build_line(vl))
            virt_lines[#virt_lines + 1] = vline:get()
        end
    end
    if #virt_lines > 0 then
        self.marks:add(self.config, 'virtual_lines', row.node.start_row, 0, {
            virt_lines = virt_lines,
            virt_lines_above = false,
        })
    end
end

---Use low priority to include pipe marks
---@private
---@param node render.md.Node
---@param side 'left'|'right'
---@param amount integer
function Render:shift(node, side, amount)
    local col = side == 'left' and node.start_col or node.end_col
    if amount > 0 then
        self.marks:add(self.config, true, node.start_row, col, {
            priority = 0,
            virt_text = self:line():pad(amount):get(),
            virt_text_pos = 'inline',
        })
    elseif amount < 0 then
        amount = amount - self.context.conceal:width('', 1)
        self.marks:add(self.config, true, node.start_row, col + amount, {
            priority = 0,
            end_col = col,
            conceal = '',
        })
    end
end

---@private
function Render:border()
    local delim = self.data.delim
    local rows = self.data.rows
    local border = self.config.border

    ---@param row render.md.table.Row
    ---@return boolean
    local function width_equal(row)
        if vim.tbl_contains({ 'trimmed', 'padded' }, self.config.cell) then
            -- assume table was modified to match
            return true
        elseif self.config.cell == 'raw' then
            -- want the computed widths to match
            for i, cell in ipairs(row.cells) do
                if cell.width ~= self.data.cols[i].width then
                    return false
                end
            end
            return true
        elseif self.config.cell == 'overlay' then
            -- want the underlying text widths to match
            return str.width(row.node.text) == str.width(delim.text)
        else
            return false
        end
    end

    local first = rows[1]
    local last = rows[#rows]
    if not width_equal(first) or not width_equal(last) then
        return
    end

    ---@param node render.md.Node
    ---@return integer
    local function get_spaces(node)
        local _, line = node:line('first', 0)
        return math.max(str.spaces('start', line or ''), node.start_col)
    end

    local first_node = first.node
    local last_node = #rows == 1 and delim or last.node
    local spaces = get_spaces(first_node)
    if spaces ~= get_spaces(last_node) then
        return
    end

    local icon = border[11]
    local parts = iter.list.map(self.data.cols, function(col)
        return icon:rep(col.width)
    end)

    ---@param node render.md.Node
    ---@param above boolean
    ---@param chars [string, string, string]
    local function table_border(node, above, chars)
        local text = chars[1] .. table.concat(parts, chars[2]) .. chars[3]
        local highlight = above and self.config.head or self.config.row
        local line = self:line():pad(spaces):text(text, highlight)

        local virtual = self.config.border_virtual
        local row, target = node:line(above and 'above' or 'below', 1)
        local available = target and str.width(target) == 0

        if not virtual and available and self.context.used:take(row) then
            self.marks:add(self.config, 'table_border', row, 0, {
                virt_text = line:get(),
                virt_text_pos = 'overlay',
            })
        else
            self.marks:add(self.config, 'virtual_lines', node.start_row, 0, {
                virt_lines = { self:indent():line(true):extend(line):get() },
                virt_lines_above = above,
            })
        end
    end

    table_border(first_node, true, { border[1], border[2], border[3] })
    if #rows > 1 then
        table_border(last_node, false, { border[7], border[8], border[9] })
    end
end

return Render
