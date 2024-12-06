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
function Row:increment(n)
    self.value = self.value + (n or 1)
    return self.value
end

---@class render.md.MarkInfo
---@field row { [1]: integer, [2]?: integer }
---@field col { [1]: integer, [2]?: integer }
---@field hl_eol? boolean
---@field hl_group? string
---@field conceal? string
---@field virt_text? { [1]: string, [2]: string|string[] }[]
---@field virt_text_pos? string
---@field virt_text_win_col? integer
---@field virt_lines? { [1]: string, [2]: string }[][]
---@field virt_lines_above? boolean
---@field sign_text? string
---@field sign_hl_group? string
---@field priority? integer
local MarkInfo = {}
MarkInfo.__index = MarkInfo

---@param row integer
---@param col integer
---@param details vim.api.keyset.extmark_details
---@return render.md.MarkInfo
function MarkInfo.new(row, col, details)
    local self = setmetatable({}, MarkInfo)
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
function MarkInfo:priorities()
    local result = {}

    local row_offset = 0
    if self.virt_lines ~= nil then
        row_offset = self.virt_lines_above and -0.5 or 0.5
    end
    vim.list_extend(result, { self.row[1] + row_offset, (self.row[2] or self.row[1]) + row_offset })

    local col = self.virt_text_win_col or 0
    vim.list_extend(result, { math.max(self.col[1], col), math.max((self.col[2] or self.col[1]), col) })

    vim.list_extend(result, {
        self.virt_text_pos == 'inline' and 0 or 1, -- Inline text comes first
        self.sign_text == nil and 0 or 1, -- Signs come later
    })

    return result
end

---@param a render.md.MarkInfo
---@param b render.md.MarkInfo
---@return boolean
function MarkInfo.__lt(a, b)
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

---@param row integer
---@param level integer
---@return render.md.MarkInfo[]
function M.heading(row, level)
    local icons = { '󰲡 ', ' 󰲣 ', '  󰲥 ', '   󰲧 ', '    󰲩 ', '     󰲫 ' }
    local foreground = M.hl(string.format('H%d', level))
    local background = M.hl(string.format('H%dBg', level))

    ---@type render.md.MarkInfo
    local sign_mark = {
        row = { row },
        col = { 0 },
        sign_text = '󰫎 ',
        sign_hl_group = M.hl_sign(foreground),
    }
    ---@type render.md.MarkInfo
    local icon_mark = {
        row = { row, row },
        col = { 0, level },
        virt_text = { { icons[level], { foreground, background } } },
        virt_text_pos = 'overlay',
    }
    ---@type render.md.MarkInfo
    local background_mark = {
        row = { row, row + 1 },
        col = { 0, 0 },
        hl_eol = true,
        hl_group = background,
    }
    return { sign_mark, icon_mark, background_mark }
end

---@param row integer
---@param col integer
---@param level integer
---@param spaces? integer
---@return render.md.MarkInfo
function M.bullet(row, col, level, spaces)
    local icons = { '●', '○', '◆', '◇' }
    spaces = spaces or 0
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { col, col + spaces + 2 },
        virt_text = { { string.rep(' ', spaces) .. icons[level], M.hl('Bullet') } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param col integer
---@param text string
---@return render.md.MarkInfo
function M.ordered(row, col, text)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { col, col + 3 },
        virt_text = { { text, M.hl('Bullet') } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.MarkInfo
function M.conceal(row, start_col, end_col)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        conceal = '',
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param highlight string
---@return render.md.MarkInfo
function M.highlight(row, start_col, end_col, highlight)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        hl_eol = false,
        hl_group = M.hl(highlight),
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.MarkInfo[]
function M.inline_highlight(row, start_col, end_col)
    return {
        M.conceal(row, start_col, start_col + 2),
        M.highlight(row, start_col, end_col, 'InlineHighlight'),
        M.conceal(row, end_col - 2, end_col),
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
        hl_group = M.hl('Code'),
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
---@param win_col? integer
---@return render.md.MarkInfo[]
function M.code_language(row, col, name, win_col)
    local icon, highlight
    if name == 'python' or name == 'py' then
        icon, highlight = '󰌠 ', 'MiniIconsYellow'
    elseif name == 'rust' or name == 'rs' then
        icon, highlight = '󱘗 ', 'MiniIconsOrange'
    elseif name == 'lua' then
        icon, highlight = '󰢱 ', 'MiniIconsAzure'
    end

    ---@type render.md.MarkInfo
    local sign_mark = {
        row = { row },
        col = { col },
        sign_text = icon,
        sign_hl_group = M.hl_sign(highlight),
    }
    ---@type render.md.MarkInfo
    local language_mark = {
        row = { row },
        col = { col + 3 },
        virt_text = { { icon .. name, { highlight, M.hl('Code') } } },
        virt_text_pos = 'inline',
    }
    local result = { sign_mark, language_mark }
    if win_col ~= nil then
        table.insert(result, M.code_hide(row, col, win_col))
    end
    table.insert(result, M.code_row(row, col))
    return result
end

---@param row integer
---@param col integer
---@param above boolean
---@param width? integer
---@return render.md.MarkInfo
function M.code_border(row, col, above, width)
    width = (width or vim.o.columns) - col
    local icon = above and '▄' or '▀'
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { col },
        virt_text = { { icon:rep(width), M.hl_bg_to_fg('Code') } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param kind 'image'|'link'|'web'
---@return render.md.MarkInfo
function M.link(row, start_col, end_col, kind)
    local icon
    if kind == 'image' then
        icon = '󰥶 '
    elseif kind == 'link' then
        icon = '󰌹 '
    elseif kind == 'web' then
        icon = '󰖟 '
    end
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        virt_text = { { icon, M.hl('Link') } },
        virt_text_pos = 'inline',
    }
end

---@param row integer
---@param format string
---@param highlight string
---@return render.md.MarkInfo
function M.quote(row, format, highlight)
    local quote = string.format(format, '▋')
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { 0, vim.fn.strdisplaywidth(quote) },
        virt_text = { { quote, M.hl(highlight) } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param col integer
---@param head boolean
---@return render.md.MarkInfo
function M.table_pipe(row, col, head)
    local highlight = head and 'TableHead' or 'TableRow'
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { col, col + 1 },
        virt_text = { { '│', M.hl(highlight) } },
        virt_text_pos = 'overlay',
    }
end

---@param row integer
---@param col integer
---@param spaces integer
---@return render.md.MarkInfo
function M.table_padding(row, col, spaces)
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { col },
        virt_text = { { string.rep(' ', spaces), M.hl('TableFill') } },
        virt_text_pos = 'inline',
        priority = 0,
    }
end

---@param row integer
---@param above boolean
---@param lengths integer[]
---@param indent? integer
---@return render.md.MarkInfo
function M.table_border(row, above, lengths, indent)
    local line = {}
    if indent ~= nil then
        table.insert(line, { string.rep(' ', indent), 'Normal' })
    end
    local parts = vim.tbl_map(function(length)
        return string.rep('─', length)
    end, lengths)
    if above then
        table.insert(line, { '┌' .. table.concat(parts, '┬') .. '┐', M.hl('TableHead') })
    else
        table.insert(line, { '└' .. table.concat(parts, '┴') .. '┘', M.hl('TableRow') })
    end
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { 0 },
        virt_lines = { line },
        virt_lines_above = above,
    }
end

---@param row integer
---@param sections (integer|integer[])[]
---@param suffix? integer
---@return render.md.MarkInfo
function M.table_delimiter(row, sections, suffix)
    local parts = vim.tbl_map(function(width_or_widths)
        local widths = vim.islist(width_or_widths) and width_or_widths or { width_or_widths }
        local section = vim.tbl_map(function(width)
            return width == 1 and '━' or string.rep('─', width)
        end, widths)
        return table.concat(section, '')
    end, sections)
    local value = '├' .. table.concat(parts, '┼') .. '┤' .. string.rep(' ', suffix or 0)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { 0, vim.fn.strdisplaywidth(value) },
        virt_text = { { value, M.hl('TableHead') } },
        virt_text_pos = 'overlay',
    }
end

---@private
---@param highlight string
---@return string
function M.hl_sign(highlight)
    return M.hl('_' .. highlight .. '_' .. M.hl('Sign'))
end

---@param base string
---@return string
function M.hl_bg_to_fg(base)
    return M.hl('_bgtofg_' .. M.hl(base))
end

---@param suffix string
---@return string
function M.hl(suffix)
    return 'RenderMarkdown' .. suffix
end

---@param marks (render.md.MarkInfo|render.md.MarkInfo[])[]
---@param screen string[]
function M.assert_view(marks, screen)
    M.assert_marks(marks)
    M.assert_screen(screen)
end

---@param expected (render.md.MarkInfo|render.md.MarkInfo[])[]
function M.assert_marks(expected)
    local actual = M.actual_marks()

    expected = vim.iter(expected)
        :map(function(mark_or_marks)
            return vim.islist(mark_or_marks) and mark_or_marks or { mark_or_marks }
        end)
        :flatten()
        :totable()

    for i = 1, math.min(#expected, #actual) do
        assert.are.same(expected[i], actual[i], string.format('Marks at index %d mismatch', i))
    end
    assert.are.same(#expected, #actual, 'Different number of marks found')
end

---@private
---@return render.md.MarkInfo[]
function M.actual_marks()
    local namespace = require('render-markdown.core.ui').namespace
    local marks = vim.api.nvim_buf_get_extmarks(0, namespace, 0, -1, { details = true })
    ---@type render.md.MarkInfo[]
    local actual = {}
    for _, mark in ipairs(marks) do
        local _, row, col, details = unpack(mark)
        table.insert(actual, MarkInfo.new(row, col, details))
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
