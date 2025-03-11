---@module 'luassert'

---@class render.md.test.Row
---@field private value integer
local Row = {}
Row.__index = Row

---@return render.md.test.Row
function Row.new()
    local self = setmetatable({}, Row)
    self.value = 0
    return self
end

---@return integer
function Row:get()
    return self.value
end

---@param n? integer
---@return integer
function Row:inc(n)
    self.value = self.value + (n or 1)
    return self.value
end

---@class render.md.test.Range
---@field [1] integer
---@field [2]? integer

---@class render.md.MarkInfo: render.md.MarkOpts
---@field row render.md.test.Range
---@field col render.md.test.Range
---@field virt_text_pos? string

---@class render.md.test.Marks
---@field private marks render.md.MarkInfo[]
local Marks = {}
Marks.__index = Marks

---@return render.md.test.Marks
function Marks.new()
    local self = setmetatable({}, Marks)
    self.marks = {}
    return self
end

---@return render.md.MarkInfo[]
function Marks:get()
    return self.marks
end

---@param mark render.md.MarkInfo
function Marks:add(mark)
    table.insert(self.marks, mark)
end

---@param marks render.md.MarkInfo[]
function Marks:extend(marks)
    vim.list_extend(self.marks, marks)
end

---@class render.md.MarkDetails: render.md.MarkInfo
local MarkDetails = {}
MarkDetails.__index = MarkDetails

---@param row integer
---@param col integer
---@param details vim.api.keyset.extmark_details
---@return render.md.MarkDetails
function MarkDetails.new(row, col, details)
    local self = setmetatable({}, MarkDetails)
    self.row = { row, details.end_row }
    self.col = { col, details.end_col }
    self.hl_eol = details.hl_eol
    self.hl_group = details.hl_group
    ---@diagnostic disable-next-line: assign-type-mismatch
    self.conceal = details.conceal
    self.virt_text = details.virt_text
    self.virt_text_pos = details.virt_text_pos
    self.virt_text_win_col = details.virt_text_win_col
    self.virt_lines = details.virt_lines
    self.virt_lines_above = details.virt_lines_above
    self.sign_text = details.sign_text
    self.sign_hl_group = details.sign_hl_group
    if details.priority ~= 4096 then
        self.priority = details.priority
    end
    return self
end

---@return integer[]
function MarkDetails:priorities()
    local result = {}

    local row_offset = 0
    if self.virt_lines ~= nil then
        row_offset = self.virt_lines_above and -0.5 or 0.5
    end
    table.insert(result, self.row[1] + row_offset)
    table.insert(result, (self.row[2] or self.row[1]) + row_offset)

    local col = self.virt_text_win_col or 0
    table.insert(result, math.max(self.col[1], col))
    table.insert(result, math.max((self.col[2] or self.col[1]), col))

    -- Inline text comes first
    table.insert(result, self.virt_text_pos == 'inline' and 0 or 1)
    -- Signs come later
    table.insert(result, self.sign_text == nil and 0 or 1)

    -- Fewer text entries comes first
    local text = #(self.virt_text or {})
    for _, line in ipairs(self.virt_lines or {}) do
        text = text + #line
    end
    table.insert(result, text)

    return result
end

---@param a render.md.MarkDetails
---@param b render.md.MarkDetails
---@return boolean
function MarkDetails.__lt(a, b)
    local as, bs = a:priorities(), b:priorities()
    for i = 1, math.max(#as, #bs) do
        if as[i] ~= bs[i] then
            return as[i] < bs[i]
        end
    end
    return false
end

---@class render.md.test.Util
local M = {}

---@param file string
---@param opts? render.md.UserConfig
function M.setup(file, opts)
    require('luassert.assert'):set_parameter('TableFormatLevel', 4)
    require('luassert.assert'):set_parameter('TableErrorHighlightColor', 'none')
    require('render-markdown').setup(opts)
    vim.cmd('e ' .. file)
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    vim.wait(0)
end

M.row = Row.new

M.marks = Marks.new

---@param row integer
---@param col render.md.test.Range
---@param text render.md.MarkText
---@param conceal? string
---@return render.md.MarkInfo
function M.inline(row, col, text, conceal)
    ---@type render.md.MarkInfo
    return {
        row = #col == 1 and { row } or { row, row },
        col = col,
        virt_text = { text },
        virt_text_pos = 'inline',
        conceal = conceal,
    }
end

---@param row integer
---@param col render.md.test.Range
---@param text render.md.MarkText
---@param conceal string?
---@return render.md.MarkInfo
function M.overlay(row, col, text, conceal)
    ---@type render.md.MarkInfo
    return {
        row = #col == 1 and { row } or { row, row },
        col = col,
        virt_text = { text },
        virt_text_pos = 'overlay',
        conceal = conceal,
    }
end

---@param row integer
---@param col render.md.test.Range
---@return render.md.MarkInfo
function M.conceal(row, col)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = col,
        conceal = '',
    }
end

---@param row integer
---@param col integer
---@param text string
---@param highlight string
---@return render.md.MarkInfo
function M.sign(row, col, text, highlight)
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { col },
        sign_text = text,
        sign_hl_group = 'RenderMarkdown_' .. highlight .. '_' .. 'RenderMarkdownSign',
    }
end

---@param row integer
---@param level integer
---@return render.md.MarkInfo[]
function M.heading(row, level)
    local icons = { '󰲡 ', ' 󰲣 ', '  󰲥 ', '   󰲧 ', '    󰲩 ', '     󰲫 ' }
    local foreground = string.format('RenderMarkdownH%d', level)
    local background = string.format('RenderMarkdownH%dBg', level)
    ---@type render.md.MarkInfo
    local background_mark = {
        row = { row, row + 1 },
        col = { 0, 0 },
        hl_eol = true,
        hl_group = background,
    }
    return {
        M.sign(row, 0, '󰫎 ', foreground),
        M.overlay(row, { 0, level }, { icons[level], { foreground, background } }),
        background_mark,
    }
end

---@param row integer
---@param col integer
---@param level integer
---@param spaces? integer
---@return render.md.MarkInfo
function M.bullet(row, col, level, spaces)
    local icons = { '●', '○', '◆', '◇' }
    spaces = spaces or 0
    local text = string.rep(' ', spaces) .. icons[level]
    return M.overlay(row, { col, col + spaces + 2 }, { text, 'RenderMarkdownBullet' })
end

---@param row integer
---@param col integer
---@param text string
---@return render.md.MarkInfo
function M.ordered(row, col, text)
    return M.overlay(row, { col, col + 3 }, { text, 'RenderMarkdownBullet' })
end

---@param row integer
---@param col render.md.test.Range
---@param kind 'code'|'inline'|'link'
---@return render.md.MarkInfo
function M.highlight(row, col, kind)
    local highlight
    if kind == 'code' then
        highlight = 'RenderMarkdownCodeInline'
    elseif kind == 'inline' then
        highlight = 'RenderMarkdownInlineHighlight'
    elseif kind == 'link' then
        highlight = 'RenderMarkdownLink'
    end
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = col,
        hl_eol = false,
        hl_group = highlight,
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.MarkInfo[]
function M.inline_highlight(row, start_col, end_col)
    return {
        M.conceal(row, { start_col, start_col + 2 }),
        M.highlight(row, { start_col, end_col }, 'inline'),
        M.conceal(row, { end_col - 2, end_col }),
    }
end

---@param row integer
---@param col integer
---@return render.md.MarkInfo
function M.code_row(row, col)
    ---@type render.md.MarkInfo
    return {
        row = { row, row + 1 },
        col = { col, 0 },
        hl_eol = true,
        hl_group = 'RenderMarkdownCode',
    }
end

---@param row integer
---@param col integer
---@param win_col integer
---@return render.md.MarkInfo
function M.code_hide(row, col, win_col)
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { col },
        virt_text = { { string.rep(' ', vim.o.columns * 2), 'Normal' } },
        virt_text_pos = 'win_col',
        virt_text_win_col = win_col,
        priority = 0,
    }
end

---@param row integer
---@param col integer
---@param name 'python'|'py'|'rust'|'rs'|'lua'
---@return render.md.MarkInfo[]
function M.code_language(row, col, name)
    local icon, highlight
    if name == 'python' or name == 'py' then
        icon, highlight = '󰌠 ', 'MiniIconsYellow'
    elseif name == 'rust' or name == 'rs' then
        icon, highlight = '󱘗 ', 'MiniIconsOrange'
    elseif name == 'lua' then
        icon, highlight = '󰢱 ', 'MiniIconsAzure'
    end
    return {
        M.sign(row, col, icon, highlight),
        M.inline(row, { col + 3 }, { icon .. name, { highlight, 'RenderMarkdownCode' } }),
    }
end

---@param row integer
---@param col integer
---@param above boolean
---@param width? integer
---@return render.md.MarkInfo
function M.code_border(row, col, above, width)
    width = (width or vim.o.columns) - col
    local icon = above and '▄' or '▀'
    return M.overlay(row, { col }, { icon:rep(width), 'RenderMarkdown_bgtofg_RenderMarkdownCode' })
end

---@param row integer
---@param col render.md.test.Range
---@param kind 'image'|'link'|'web'
---@return render.md.MarkInfo
function M.link(row, col, kind)
    local icon
    if kind == 'image' then
        icon = '󰥶 '
    elseif kind == 'link' then
        icon = '󰌹 '
    elseif kind == 'web' then
        icon = '󰖟 '
    end
    return M.inline(row, col, { icon, 'RenderMarkdownLink' })
end

---@param row integer
---@param format string
---@param highlight string
---@return render.md.MarkInfo
function M.quote(row, format, highlight)
    local text = string.format(format, '▋')
    return M.overlay(row, { 0, vim.fn.strdisplaywidth(text) }, { text, highlight })
end

---@param row integer
---@param col integer
---@param spaces integer
---@param kind? 'code'|'table'
---@return render.md.MarkInfo
function M.padding(row, col, spaces, kind)
    local highlight
    if kind == 'code' then
        highlight = 'RenderMarkdownCodeInline'
    elseif kind == 'table' then
        highlight = 'RenderMarkdownTableFill'
    else
        highlight = 'Normal'
    end
    local mark = M.inline(row, { col }, { string.rep(' ', spaces), highlight })
    mark.priority = 0
    return mark
end

---@param row integer
---@param col integer
---@param head boolean
---@return render.md.MarkInfo
function M.table_pipe(row, col, head)
    local highlight = head and 'RenderMarkdownTableHead' or 'RenderMarkdownTableRow'
    return M.overlay(row, { col, col + 1 }, { '│', highlight })
end

---@param row integer
---@param above boolean
---@param lengths integer[]
---@return render.md.MarkInfo
function M.table_border(row, above, lengths)
    local parts = vim.tbl_map(function(length)
        return string.rep('─', length)
    end, lengths)
    local text, highlight
    if above then
        text, highlight = '┌' .. table.concat(parts, '┬') .. '┐', 'RenderMarkdownTableHead'
    else
        text, highlight = '└' .. table.concat(parts, '┴') .. '┘', 'RenderMarkdownTableRow'
    end
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { 0 },
        virt_lines = { { { text, highlight } } },
        virt_lines_above = above,
    }
end

---@param row integer
---@param col integer
---@param sections (integer|integer[])[]
---@return render.md.MarkInfo
function M.table_delimiter(row, col, sections)
    local parts = vim.tbl_map(function(width)
        local widths = vim.islist(width) and width or { width }
        local section = vim.tbl_map(function(amount)
            return amount == 1 and '━' or string.rep('─', amount)
        end, widths)
        return table.concat(section, '')
    end, sections)
    local text = '├' .. table.concat(parts, '┼') .. '┤'
    local difference = col - vim.fn.strdisplaywidth(text)
    if difference > 0 then
        text = text .. string.rep(' ', difference)
    end
    return M.overlay(row, { 0, col }, { text, 'RenderMarkdownTableHead' })
end

---@param marks render.md.test.Marks
---@param screen string[]
function M.assert_view(marks, screen)
    M.assert_marks(marks:get())
    M.assert_screen(screen)
end

---@param expected render.md.MarkInfo[]
function M.assert_marks(expected)
    local actual = M.actual_marks()
    for i = 1, math.min(#expected, #actual) do
        assert.are.same(expected[i], actual[i], string.format('Marks at index %d mismatch', i))
    end
    assert.are.same(#expected, #actual, 'Different number of marks found')
end

---@private
---@return render.md.MarkInfo[]
function M.actual_marks()
    local ui = require('render-markdown.core.ui')
    local marks = vim.api.nvim_buf_get_extmarks(0, ui.ns, 0, -1, { details = true })
    ---@type render.md.MarkDetails[]
    local actual = {}
    for _, mark in ipairs(marks) do
        local _, row, col, details = unpack(mark)
        table.insert(actual, MarkDetails.new(row, col, details))
    end
    table.sort(actual)
    return actual
end

---@param expected string[]
function M.assert_screen(expected)
    local actual = M.actual_screen()
    assert.are.same(expected, actual)
end

---@private
---@return string[]
function M.actual_screen()
    vim.cmd('redraw')

    local actual = {}
    for row = 1, vim.o.lines do
        local line = ''
        for col = 1, vim.o.columns do
            line = line .. vim.fn.screenstring(row, col)
        end
        -- Remove tailing whitespace to make tests easier to write
        line = line:gsub('%s+$', '')
        -- Stop collecting lines once we reach an empty one
        if line == '~' then
            break
        end
        table.insert(actual, line)
    end
    return actual
end

return M
