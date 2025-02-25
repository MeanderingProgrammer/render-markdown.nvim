---@module 'luassert'

local util = require('tests.util')

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
        { icon:rep(vim.o.columns), background },
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

---@param lengths integer[]
---@return render.md.Line
local function indent_line(lengths)
    local result = {}
    for _, length in ipairs(lengths) do
        if length == 1 then
            table.insert(result, { '▎', util.hl('Indent') })
        else
            table.insert(result, { string.rep(' ', length), 'Normal' })
        end
    end
    return result
end

---@param row integer
---@param lengths integer[]
---@return render.md.MarkInfo
local function indent(row, lengths)
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { 0 },
        virt_text = indent_line(lengths),
        virt_text_pos = 'inline',
        priority = 0,
    }
end

---@param mark render.md.MarkInfo
---@param lengths integer[]
---@return render.md.MarkInfo
local function indent_mark(mark, lengths)
    local line = indent_line(lengths)
    vim.list_extend(line, mark.virt_lines[1])
    mark.virt_lines = { line }
    return mark
end

describe('indent.md', function()
    it('with heading border & no icon', function()
        util.setup('tests/data/indent.md', {
            heading = { border = true },
            indent = { enabled = true, icon = '' },
        })

        local expected, row = {}, util.row()

        local l2, l3 = { 2 }, { 4 }

        vim.list_extend(expected, {
            border(row:get(), 2, 'above'),
            indent(row:get(), l2),
            util.heading(row:get(), 2),
            indent(row:increment(), l2),
        })
        vim.list_extend(expected, {
            indent_mark(util.table_border(row:increment(), true, { 5, 5 }), l2),
            indent(row:get(), l2),
            util.table_pipe(row:get(), 0, true),
            util.table_pipe(row:get(), 6, true),
            util.table_pipe(row:get(), 12, true),
            indent(row:increment(), l2),
            util.table_delimiter(row:get(), { 5, 5 }),
        })

        vim.list_extend(expected, {
            border(row:increment(), 1, 'above'),
            util.heading(row:increment(), 1),
            border(row:increment(), 1, 'below'),
        })

        vim.list_extend(expected, {
            indent(row:increment(2), l3),
            border(row:get(), 3, 'above'),
            indent(row:increment(), l3),
            util.heading(row:get(), 3),
            indent(row:increment(), l3),
            border(row:get(), 3, 'below'),
        })
        vim.list_extend(expected, {
            indent(row:increment(), l3),
        })

        util.assert_view(expected, {
            '󰫎   1    󰲣 Heading 2',
            '    2',
            '        ┌─────┬─────┐',
            '    3   │ Foo │ Bar │',
            '    4   ├─────┼─────┤',
            '    5 ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   6 󰲡 Heading 1',
            '    7 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '    8 Foo',
            '    9     ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎  10       󰲥 Heading 3',
            '   11     ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '   12     Bar',
        })
    end)

    it('with per_level & skip_level', function()
        util.setup('tests/data/indent.md', {
            indent = { enabled = true, per_level = 4, skip_level = 0 },
        })

        local expected, row = {}, util.row()

        local l1, l2 = { 1, 3 }, { 1, 3, 1, 3 }

        vim.list_extend(expected, {
            indent(row:get(), l2),
            util.heading(row:get(), 2),
            indent(row:increment(), l2),
        })
        vim.list_extend(expected, {
            indent_mark(util.table_border(row:increment(), true, { 5, 5 }), l2),
            indent(row:get(), l2),
            util.table_pipe(row:get(), 0, true),
            util.table_pipe(row:get(), 6, true),
            util.table_pipe(row:get(), 12, true),
            indent(row:increment(), l2),
            util.table_delimiter(row:get(), { 5, 5 }),
        })

        vim.list_extend(expected, {
            indent(row:increment(), l1),
            indent(row:increment(), l1),
            util.heading(row:get(), 1),
            indent(row:increment(), l1),
        })
        vim.list_extend(expected, {
            indent(row:increment(), l1),
        })

        vim.list_extend(expected, {
            indent(row:increment(), l1),
            indent(row:get(), l2),
            indent(row:increment(), l1),
            indent(row:get(), l2),
            util.heading(row:get(), 3),
            indent(row:increment(), l1),
            indent(row:get(), l2),
        })
        vim.list_extend(expected, {
            indent(row:increment(), l1),
            indent(row:get(), l2),
        })

        util.assert_view(expected, {
            '󰫎   1 ▎   ▎    󰲣 Heading 2',
            '    2 ▎   ▎',
            '      ▎   ▎   ┌─────┬─────┐',
            '    3 ▎   ▎   │ Foo │ Bar │',
            '    4 ▎   ▎   ├─────┼─────┤',
            '    5 ▎',
            '󰫎   6 ▎   󰲡 Heading 1',
            '    7 ▎',
            '    8 ▎   Foo',
            '    9 ▎   ▎   ▎',
            '󰫎  10 ▎   ▎   ▎     󰲥 Heading 3',
            '   11 ▎   ▎   ▎',
            '   12 ▎   ▎   ▎   Bar',
        })
    end)
end)
