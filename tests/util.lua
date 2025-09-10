---@module 'luassert'

---@class render.md.test.Range
---@field [1] integer
---@field [2]? integer

---@class render.md.test.MarkInfo: render.md.mark.Opts
---@field row render.md.test.Range
---@field col render.md.test.Range

---@class render.md.test.Util
local M = {}

---@class render.md.test.util.Setup
M.setup = {}

---@private
---@param opts? render.md.UserConfig
function M.setup.init(opts)
    require('luassert.assert'):set_parameter('TableFormatLevel', 4)
    require('luassert.assert'):set_parameter('TableErrorHighlightColor', 'none')
    ---@type render.md.UserConfig
    local test_config = {
        anti_conceal = { enabled = false },
        win_options = { concealcursor = { rendered = 'nvic' } },
        overrides = {
            buftype = {
                nofile = {
                    padding = { highlight = 'Normal' },
                    sign = { enabled = true },
                },
            },
        },
    }
    local config = vim.tbl_deep_extend('force', test_config, opts or {})
    require('render-markdown').setup(config)
end

---@param file string
---@param opts? render.md.UserConfig
function M.setup.file(file, opts)
    M.setup.init(opts)
    vim.cmd('e ' .. file)
    vim.wait(0)
end

---@param lines string[]
---@param opts? render.md.UserConfig
function M.setup.text(lines, opts)
    M.setup.init(opts)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = 'markdown'
    vim.wait(0)
end

M.row = require('tests.helpers.row').new

M.marks = require('tests.helpers.marks').new

M.system = require('tests.helpers.system')

---@return vim.api.keyset.set_extmark
function M.conceal()
    ---@type vim.api.keyset.set_extmark
    return { conceal = '' }
end

---@return vim.api.keyset.set_extmark
function M.conceal_lines()
    ---@type vim.api.keyset.set_extmark
    return { conceal_lines = '' }
end

---@param kind 'code'|'inline'|'link'
---@return vim.api.keyset.set_extmark
function M.highlight(kind)
    local priority ---@type integer?
    local highlight ---@type string
    if kind == 'code' then
        highlight = 'RmCodeInline'
    elseif kind == 'inline' then
        highlight = 'RmInlineHighlight'
    elseif kind == 'link' then
        priority = 1000
        highlight = 'RmLink'
    end
    ---@type vim.api.keyset.set_extmark
    return {
        priority = priority,
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
        virt_text = {
            { (' '):rep(spaces or 0) .. icons[level], 'RmBullet' },
        },
        virt_text_pos = 'overlay',
    }
end

---@param level integer
---@return vim.api.keyset.set_extmark
function M.ordered(level)
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { ('%d.'):format(level), 'RmBullet' } },
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
        hl_mode = 'combine',
        virt_text = { { icons[kind], highlight } },
        virt_text_pos = 'inline',
    }
end

---@param highlight string
---@return vim.api.keyset.set_extmark
function M.quote(highlight)
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { '▋', highlight } },
        virt_text_pos = 'overlay',
    }
end

---@param spaces integer
---@param priority? integer
---@param highlight? string
---@return vim.api.keyset.set_extmark
function M.padding(spaces, priority, highlight)
    ---@type vim.api.keyset.set_extmark
    return {
        priority = priority or 100,
        virt_text = { { (' '):rep(spaces), highlight or 'Normal' } },
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
---@return render.md.mark.Line
function M.indent.line(lengths)
    local result = {} ---@type render.md.mark.Line
    for _, length in ipairs(lengths) do
        if length == 1 then
            result[#result + 1] = { '▎', 'RmIndent' }
        else
            result[#result + 1] = { (' '):rep(length), 'Normal' }
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
        sign_hl_group = ('Rm_RmH%d_RmSign'):format(level),
    }
end

---@param level integer
---@return vim.api.keyset.set_extmark
function M.heading.icon(level)
    local icons =
        { '󰲡 ', ' 󰲣 ', '  󰲥 ', '   󰲧 ', '    󰲩 ', '     󰲫 ' }
    local highlight = ('RmH%d:RmH%dBg'):format(level, level)
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
        hl_group = ('RmH%dBg'):format(level),
    }
end

---@class render.md.test.Code
M.code = {}

---@param name render.md.test.Language
---@return vim.api.keyset.set_extmark
function M.code.sign(name)
    local icon = assert(M.code.icon(name))
    ---@type vim.api.keyset.set_extmark
    return {
        sign_text = icon[1],
        sign_hl_group = ('Rm_%s_RmSign'):format(icon[2]),
    }
end

---@param border string
---@param full boolean
---@param ... render.md.test.Language|string|integer
---@return vim.api.keyset.set_extmark
function M.code.border(border, full, ...)
    local parts = { ... }
    parts[#parts + 1] = full and vim.o.columns or nil

    local line = {} ---@type render.md.mark.Line
    for _, part in ipairs(parts) do
        if type(part) == 'string' then
            local icon = M.code.icon(part)
            if icon then
                local icon_hl = ('%s:RmCodeBorder'):format(icon[2])
                line[#line + 1] = { icon[1], icon_hl }
                line[#line + 1] = { part, icon_hl }
            else
                line[#line + 1] = { part, 'RmCodeInfo:RmCodeBorder' }
            end
        elseif type(part) == 'number' then
            line[#line + 1] = { border:rep(part), 'Rm_RmCodeBorder_bg_as_fg' }
        else
            error(('invalid border part type: %s'):format(type(part)))
        end
    end
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = line,
        virt_text_pos = 'overlay',
    }
end

---@alias render.md.test.Language 'python'|'py'|'rust'|'rs'|'lua'

---@class render.md.test.Icon
---@field [1] string
---@field [2] string

---@private
---@param name render.md.test.Language
---@return render.md.test.Icon?
function M.code.icon(name)
    if name == 'python' or name == 'py' then
        ---@type render.md.test.Icon
        return { '󰌠 ', 'MiniIconsYellow' }
    elseif name == 'rust' or name == 'rs' then
        ---@type render.md.test.Icon
        return { '󱘗 ', 'MiniIconsOrange' }
    elseif name == 'lua' then
        ---@type render.md.test.Icon
        return { '󰢱 ', 'MiniIconsAzure' }
    else
        return nil
    end
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
        virt_text = { { (' '):rep(vim.o.columns * 2), 'Normal' } },
        virt_text_pos = 'win_col',
        virt_text_win_col = width,
    }
end

---@param kind 'block'|'inline'
---@param spaces integer
---@return vim.api.keyset.set_extmark
function M.code.padding(kind, spaces)
    local priority = kind == 'inline' and 0 or nil
    local highlight = kind == 'inline' and 'RmCodeInline' or 'RmCode'
    return M.padding(spaces, priority, highlight)
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

---@param virtual boolean
---@param above boolean
---@param ... integer
---@return vim.api.keyset.set_extmark
function M.table.border(virtual, above, ...)
    local chars = above and { '┌', '┬', '┐' } or { '└', '┴', '┘' }
    local highlight = above and 'RmTableHead' or 'RmTableRow'
    local inner = vim.iter({ ... })
        :map(function(length)
            return ('─'):rep(length)
        end)
        :join(chars[2])
    local text = chars[1] .. inner .. chars[3]
    if virtual then
        ---@type vim.api.keyset.set_extmark
        return {
            virt_lines = { { { text, highlight } } },
            virt_lines_above = above,
        }
    else
        ---@type vim.api.keyset.set_extmark
        return {
            virt_text = { { text, highlight } },
            virt_text_pos = 'overlay',
        }
    end
end

---@param padding integer
---@param ... integer[]
---@return vim.api.keyset.set_extmark
function M.table.delimiter(padding, ...)
    local inner = vim.iter({ ... })
        :map(function(widths)
            return vim.iter(widths)
                :map(function(amount)
                    return amount == 1 and '━' or ('─'):rep(amount)
                end)
                :join('')
        end)
        :join('┼')
    local line = { { '├' .. inner .. '┤', 'RmTableHead' } }
    if padding > 0 then
        line[#line + 1] = { (' '):rep(padding), 'Normal' }
    end
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = line,
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
        local message = ('marks at index %d mismatch'):format(i)
        assert.same(expected[i], actual[i], message)
    end
    assert.same(#expected, #actual, 'different number of marks found')
end

---@private
---@return render.md.test.MarkInfo[]
function M.actual_marks()
    local ui = require('render-markdown.core.ui')
    local marks = vim.api.nvim_buf_get_extmarks(0, ui.ns, 0, -1, {
        details = true,
    })
    local actual = {} ---@type render.md.test.MarkDetails[]
    for _, mark in ipairs(marks) do
        local row, col = mark[2], mark[3]
        local details = assert(mark[4], 'missing details')
        local info = require('tests.helpers.details').new(row, col, details)
        actual[#actual + 1] = info
    end
    table.sort(actual)
    return actual
end

---@param expected string[]
function M.assert_screen(expected)
    local actual = M.actual_screen()
    assert.same(expected, actual)
end

---@private
---@return string[]
function M.actual_screen()
    vim.cmd('redraw')

    local actual = {} ---@type string[]
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
        actual[#actual + 1] = line
    end
    return actual
end

return M
