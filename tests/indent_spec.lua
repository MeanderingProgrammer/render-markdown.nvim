---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param level? integer
---@return render.md.MarkInfo
local function indent(row, level)
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { 0 },
        virt_text = { { string.rep('  ', level or 1), 'Normal' } },
        virt_text_pos = 'inline',
        priority = 0,
    }
end

---@param row integer
---@param level integer
---@param position 'above'|'below'
---@return render.md.MarkInfo
local function border(row, level, position)
    local foreground = util.hl(string.format('H%d', level))
    local background = util.hl_bg_to_fg(string.format('H%dBg', level))
    local icon = position == 'above' and '▄' or '▀'
    local line = {
        { '', 'Normal' },
        { '', background },
        { '', foreground },
        { icon:rep(vim.opt.columns:get()), background },
    }
    local virtual = row == 0 and position == 'above'
    if virtual then
        table.insert(line, 1, { '  ', 'Normal' })
    end
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { 0 },
        virt_text = not virtual and line or nil,
        virt_text_pos = not virtual and 'overlay' or nil,
        virt_lines = virtual and { line } or nil,
        virt_lines_above = virtual and position == 'above' or nil,
    }
end

describe('indent.md', function()
    it('custom', function()
        util.setup('tests/data/indent.md', {
            heading = { border = true },
            indent = { enabled = true },
        })

        local expected, row = {}, util.row()

        vim.list_extend(expected, {
            border(row:get(), 2, 'above'),
            indent(row:get()),
            util.heading(row:get(), 2),
            indent(row:increment()),
            border(row:get(), 2, 'below'),
        })
        vim.list_extend(expected, {
            util.table_border(row:increment(), true, { 5, 5 }, 2),
            indent(row:get()),
            util.table_pipe(row:get(), 0, true),
            util.table_pipe(row:get(), 6, true),
            util.table_pipe(row:get(), 12, true),
            indent(row:increment()),
            util.table_delimiter(row:get(), { 5, 5 }),
        })

        vim.list_extend(expected, {
            border(row:increment(), 1, 'above'),
            util.heading(row:increment(), 1),
            border(row:increment(), 1, 'below'),
        })

        vim.list_extend(expected, {
            indent(row:increment(2), 2),
            border(row:get(), 3, 'above'),
            indent(row:increment(), 2),
            util.heading(row:get(), 3),
            indent(row:increment(), 2),
            border(row:get(), 3, 'below'),
        })
        table.insert(expected, indent(row:increment(), 2))

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
