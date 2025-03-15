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

---@return vim.api.keyset.set_extmark
function M.conceal()
    ---@type vim.api.keyset.set_extmark
    return { conceal = '' }
end

---@param kind 'code'|'inline'|'link'
---@return vim.api.keyset.set_extmark
function M.highlight(kind)
    local highlight
    if kind == 'code' then
        highlight = 'RmCodeInline'
    elseif kind == 'inline' then
        highlight = 'RmInlineHighlight'
    elseif kind == 'link' then
        highlight = 'RmLink'
    end
    ---@type vim.api.keyset.set_extmark
    return {
        hl_eol = false,
        hl_group = highlight,
    }
end

---@param level integer
---@param spaces? integer
---@return vim.api.keyset.set_extmark
function M.bullet(level, spaces)
    local icons = { '●', '○', '◆', '◇' }
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { string.rep(' ', spaces or 0) .. icons[level], 'RmBullet' } },
        virt_text_pos = 'overlay',
    }
end

---@param kind 'email'|'git'|'image'|'link'|'web'|'wiki'|'youtube'
---@return vim.api.keyset.set_extmark
function M.link(kind)
    local icons = {
        email = '󰀓 ',
        git = '󰊤 ',
        image = '󰥶 ',
        link = '󰌹 ',
        web = '󰖟 ',
        wiki = '󱗖 ',
        youtube = '󰗃 ',
    }
    local highlight = kind == 'wiki' and 'RmWikiLink' or 'RmLink'
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { icons[kind], highlight } },
        virt_text_pos = 'inline',
    }
end

---@param format string
---@param highlight string
---@return vim.api.keyset.set_extmark
function M.quote(format, highlight)
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { string.format(format, '▋'), highlight } },
        virt_text_pos = 'overlay',
    }
end

---@param spaces integer
---@param priority integer
---@param highlight? string
---@return vim.api.keyset.set_extmark
function M.padding(spaces, priority, highlight)
    ---@type vim.api.keyset.set_extmark
    return {
        priority = priority,
        virt_text = { { string.rep(' ', spaces), highlight or 'Normal' } },
        virt_text_pos = 'inline',
    }
end

---@class render.md.test.Indent
M.indent = {}

---@param lengths integer[]
---@return vim.api.keyset.set_extmark
function M.indent.inline(lengths)
    ---@type vim.api.keyset.set_extmark
    return {
        priority = 0,
        virt_text = M.indent.line(lengths),
        virt_text_pos = 'inline',
    }
end

---@param opts vim.api.keyset.set_extmark
---@param lengths integer[]
---@return vim.api.keyset.set_extmark
function M.indent.virtual(opts, lengths)
    local line = M.indent.line(lengths)
    vim.list_extend(line, opts.virt_lines[1])
    opts.virt_lines = { line }
    return opts
end

---@private
---@param lengths integer[]
---@return render.md.MarkLine
function M.indent.line(lengths)
    local result = {}
    for _, length in ipairs(lengths) do
        if length == 1 then
            table.insert(result, { '▎', 'RmIndent' })
        else
            table.insert(result, { string.rep(' ', length), 'Normal' })
        end
    end
    return result
end

---@class render.md.test.Heading
M.heading = {}

---@param level integer
---@return vim.api.keyset.set_extmark
function M.heading.sign(level)
    ---@type vim.api.keyset.set_extmark
    return {
        sign_text = '󰫎 ',
        sign_hl_group = string.format('Rm_RmH%d_RmSign', level),
    }
end

---@param level integer
---@return vim.api.keyset.set_extmark
function M.heading.icon(level)
    local icons = { '󰲡 ', ' 󰲣 ', '  󰲥 ', '   󰲧 ', '    󰲩 ', '     󰲫 ' }
    local highlight = string.format('RmH%d:RmH%dBg', level, level)
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { icons[level], highlight } },
        virt_text_pos = 'overlay',
    }
end

---@param level integer
---@return vim.api.keyset.set_extmark
function M.heading.bg(level)
    ---@type vim.api.keyset.set_extmark
    return {
        hl_eol = true,
        hl_group = string.format('RmH%dBg', level),
    }
end

---@class render.md.test.Code
M.code = {}

---@param name 'python'|'py'|'rust'|'rs'|'lua'
---@return vim.api.keyset.set_extmark
function M.code.sign(name)
    local icon, highlight
    if name == 'python' or name == 'py' then
        icon, highlight = '󰌠 ', 'MiniIconsYellow'
    elseif name == 'rust' or name == 'rs' then
        icon, highlight = '󱘗 ', 'MiniIconsOrange'
    elseif name == 'lua' then
        icon, highlight = '󰢱 ', 'MiniIconsAzure'
    end
    ---@type vim.api.keyset.set_extmark
    return {
        sign_text = icon,
        sign_hl_group = string.format('Rm_%s_RmSign', highlight),
    }
end

---@param name 'python'|'py'|'rust'|'rs'|'lua'
---@return vim.api.keyset.set_extmark
function M.code.icon(name)
    local icon, highlight
    if name == 'python' or name == 'py' then
        icon, highlight = '󰌠 ', 'MiniIconsYellow'
    elseif name == 'rust' or name == 'rs' then
        icon, highlight = '󱘗 ', 'MiniIconsOrange'
    elseif name == 'lua' then
        icon, highlight = '󰢱 ', 'MiniIconsAzure'
    end
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { icon .. name, highlight .. ':' .. 'RmCode' } },
        virt_text_pos = 'inline',
    }
end

---@return vim.api.keyset.set_extmark
function M.code.bg()
    ---@type vim.api.keyset.set_extmark
    return {
        hl_eol = true,
        hl_group = 'RmCode',
    }
end

---@param width integer
---@return vim.api.keyset.set_extmark
function M.code.hide(width)
    ---@type vim.api.keyset.set_extmark
    return {
        priority = 0,
        virt_text = { { string.rep(' ', vim.o.columns * 2), 'Normal' } },
        virt_text_pos = 'win_col',
        virt_text_win_col = width,
    }
end

---@param above boolean
---@param width integer
---@return vim.api.keyset.set_extmark
function M.code.border(above, width)
    local icon = above and '▄' or '▀'
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { icon:rep(width), 'Rm_bgtofg_RmCode' } },
        virt_text_pos = 'overlay',
    }
end

---@param spaces integer
---@return vim.api.keyset.set_extmark
function M.code.padding(spaces)
    return M.padding(spaces, 0, 'RmCodeInline')
end

---@class render.md.test.Table
M.table = {}

---@param head boolean
---@return vim.api.keyset.set_extmark
function M.table.pipe(head)
    local highlight = head and 'RmTableHead' or 'RmTableRow'
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { '│', highlight } },
        virt_text_pos = 'overlay',
    }
end

---@param above boolean
---@param lengths integer[]
---@return vim.api.keyset.set_extmark
function M.table.border(above, lengths)
    local chars = above and { '┌', '┬', '┐' } or { '└', '┴', '┘' }
    local highlight = above and 'RmTableHead' or 'RmTableRow'
    local parts = vim.tbl_map(function(length)
        return string.rep('─', length)
    end, lengths)
    local text = chars[1] .. table.concat(parts, chars[2]) .. chars[3]
    ---@type vim.api.keyset.set_extmark
    return {
        virt_lines = { { { text, highlight } } },
        virt_lines_above = above,
    }
end

---@param sections integer[][]
---@param padding? integer
---@return vim.api.keyset.set_extmark
function M.table.delimiter(sections, padding)
    local parts = vim.tbl_map(function(widths)
        local section = vim.tbl_map(function(amount)
            return amount == 1 and '━' or string.rep('─', amount)
        end, widths)
        return table.concat(section, '')
    end, sections)
    local text = '├' .. table.concat(parts, '┼') .. '┤' .. string.rep(' ', padding or 0)
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { text, 'RmTableHead' } },
        virt_text_pos = 'overlay',
    }
end

---@param spaces integer
---@return vim.api.keyset.set_extmark
function M.table.padding(spaces)
    return M.padding(spaces, 0, 'RmTableFill')
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
