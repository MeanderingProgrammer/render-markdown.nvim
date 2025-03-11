---@module 'luassert'

---@class render.md.test.Range
---@field [1] integer
---@field [2]? integer

---@class render.md.test.MarkInfo: render.md.MarkOpts
---@field row render.md.test.Range
---@field col render.md.test.Range
---@field virt_text_pos? string

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

M.row = require('tests.helpers.row').new

M.marks = require('tests.helpers.marks').new

---@param row integer
---@param col render.md.test.Range
---@param text render.md.MarkText
---@param conceal? string
---@return render.md.test.MarkInfo
function M.inline(row, col, text, conceal)
    ---@type render.md.test.MarkInfo
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
---@return render.md.test.MarkInfo
function M.overlay(row, col, text, conceal)
    ---@type render.md.test.MarkInfo
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
---@return render.md.test.MarkInfo
function M.conceal(row, col)
    ---@type render.md.test.MarkInfo
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
---@return render.md.test.MarkInfo
function M.sign(row, col, text, highlight)
    ---@type render.md.test.MarkInfo
    return {
        row = { row },
        col = { col },
        sign_text = text,
        sign_hl_group = 'Rm_' .. highlight .. '_RmSign',
    }
end

---@param row integer
---@param level integer
---@return render.md.test.MarkInfo[]
function M.heading(row, level)
    local icons = { '󰲡 ', ' 󰲣 ', '  󰲥 ', '   󰲧 ', '    󰲩 ', '     󰲫 ' }
    local foreground = string.format('RmH%d', level)
    local background = string.format('RmH%dBg', level)
    ---@type render.md.test.MarkInfo
    local background_mark = {
        row = { row, row + 1 },
        col = { 0, 0 },
        hl_eol = true,
        hl_group = background,
    }
    return {
        M.sign(row, 0, '󰫎 ', foreground),
        M.overlay(row, { 0, level }, { icons[level], foreground .. ':' .. background }),
        background_mark,
    }
end

---@param row integer
---@param col integer
---@param level integer
---@param spaces? integer
---@return render.md.test.MarkInfo
function M.bullet(row, col, level, spaces)
    local icons = { '●', '○', '◆', '◇' }
    spaces = spaces or 0
    local text = string.rep(' ', spaces) .. icons[level]
    return M.overlay(row, { col, col + spaces + 2 }, { text, 'RmBullet' })
end

---@param row integer
---@param col integer
---@param text string
---@return render.md.test.MarkInfo
function M.ordered(row, col, text)
    return M.overlay(row, { col, col + 3 }, { text, 'RmBullet' })
end

---@param row integer
---@param col render.md.test.Range
---@param kind 'code'|'inline'|'link'
---@return render.md.test.MarkInfo
function M.highlight(row, col, kind)
    local highlight
    if kind == 'code' then
        highlight = 'RmCodeInline'
    elseif kind == 'inline' then
        highlight = 'RmInlineHighlight'
    elseif kind == 'link' then
        highlight = 'RmLink'
    end
    ---@type render.md.test.MarkInfo
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
---@return render.md.test.MarkInfo[]
function M.inline_highlight(row, start_col, end_col)
    return {
        M.conceal(row, { start_col, start_col + 2 }),
        M.highlight(row, { start_col, end_col }, 'inline'),
        M.conceal(row, { end_col - 2, end_col }),
    }
end

---@param row integer
---@param col integer
---@return render.md.test.MarkInfo
function M.code_row(row, col)
    ---@type render.md.test.MarkInfo
    return {
        row = { row, row + 1 },
        col = { col, 0 },
        hl_eol = true,
        hl_group = 'RmCode',
    }
end

---@param row integer
---@param col integer
---@param win_col integer
---@return render.md.test.MarkInfo
function M.code_hide(row, col, win_col)
    ---@type render.md.test.MarkInfo
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
---@return render.md.test.MarkInfo[]
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
        M.inline(row, { col + 3 }, { icon .. name, highlight .. ':' .. 'RmCode' }),
    }
end

---@param row integer
---@param col integer
---@param above boolean
---@param width? integer
---@return render.md.test.MarkInfo
function M.code_border(row, col, above, width)
    width = (width or vim.o.columns) - col
    local icon = above and '▄' or '▀'
    return M.overlay(row, { col }, { icon:rep(width), 'Rm_bgtofg_RmCode' })
end

---@param row integer
---@param col render.md.test.Range
---@param kind 'image'|'link'|'web'
---@return render.md.test.MarkInfo
function M.link(row, col, kind)
    local icon
    if kind == 'image' then
        icon = '󰥶 '
    elseif kind == 'link' then
        icon = '󰌹 '
    elseif kind == 'web' then
        icon = '󰖟 '
    end
    return M.inline(row, col, { icon, 'RmLink' })
end

---@param row integer
---@param format string
---@param highlight string
---@return render.md.test.MarkInfo
function M.quote(row, format, highlight)
    local text = string.format(format, '▋')
    return M.overlay(row, { 0, vim.fn.strdisplaywidth(text) }, { text, highlight })
end

---@param row integer
---@param col integer
---@param spaces integer
---@param kind? 'code'|'table'
---@return render.md.test.MarkInfo
function M.padding(row, col, spaces, kind)
    local highlight
    if kind == 'code' then
        highlight = 'RmCodeInline'
    elseif kind == 'table' then
        highlight = 'RmTableFill'
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
---@return render.md.test.MarkInfo
function M.table_pipe(row, col, head)
    local highlight = head and 'RmTableHead' or 'RmTableRow'
    return M.overlay(row, { col, col + 1 }, { '│', highlight })
end

---@param row integer
---@param above boolean
---@param lengths integer[]
---@return render.md.test.MarkInfo
function M.table_border(row, above, lengths)
    local parts = vim.tbl_map(function(length)
        return string.rep('─', length)
    end, lengths)
    local text, highlight
    if above then
        text, highlight = '┌' .. table.concat(parts, '┬') .. '┐', 'RmTableHead'
    else
        text, highlight = '└' .. table.concat(parts, '┴') .. '┘', 'RmTableRow'
    end
    ---@type render.md.test.MarkInfo
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
---@return render.md.test.MarkInfo
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
    return M.overlay(row, { 0, col }, { text, 'RmTableHead' })
end

---@param marks render.md.test.Marks
---@param screen string[]
function M.assert_view(marks, screen)
    M.assert_marks(marks:get())
    M.assert_screen(screen)
end

---@param expected render.md.test.MarkInfo[]
function M.assert_marks(expected)
    local actual = M.actual_marks()
    for i = 1, math.min(#expected, #actual) do
        assert.are.same(expected[i], actual[i], string.format('Marks at index %d mismatch', i))
    end
    assert.are.same(#expected, #actual, 'Different number of marks found')
end

---@private
---@return render.md.test.MarkInfo[]
function M.actual_marks()
    local ui = require('render-markdown.core.ui')
    local marks = vim.api.nvim_buf_get_extmarks(0, ui.ns, 0, -1, { details = true })
    ---@type render.md.test.MarkDetails[]
    local actual = {}
    for _, mark in ipairs(marks) do
        local _, row, col, details = unpack(mark)
        table.insert(actual, require('tests.helpers.details').new(row, col, details))
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
