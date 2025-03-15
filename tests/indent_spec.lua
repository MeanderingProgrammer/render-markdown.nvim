---@module 'luassert'

local util = require('tests.util')

---@param level integer
---@param position 'above'|'below'
---@param virtual boolean
---@return vim.api.keyset.set_extmark
local function border(level, position, virtual)
    local line = {}
    if virtual then
        table.insert(line, { '  ', 'Normal' })
    end
    local icon = position == 'above' and '▄' or '▀'
    local background = string.format('Rm_bgtofg_RmH%dBg', level)
    table.insert(line, { icon:rep(vim.o.columns), background })
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = not virtual and line or nil,
        virt_text_pos = not virtual and 'overlay' or nil,
        virt_lines = virtual and { line } or nil,
        virt_lines_above = virtual and position == 'above' or nil,
    }
end

describe('indent.md', function()
    it('with heading border & no icon', function()
        util.setup('tests/data/indent.md', {
            heading = { border = true },
            indent = { enabled = true, icon = '' },
        })

        local marks, row = util.marks(), util.row()

        local l2, l3 = { 2 }, { 4 }

        marks
            :add(row:get(), nil, 0, nil, border(2, 'above', true))
            :add(row:get(), nil, 0, nil, util.heading.sign(2))
            :add(row:get(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), row:get(), 0, 2, util.heading.icon(2))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(2))

        marks:add(row:get(), nil, 0, nil, util.indent.inline(l2))

        marks:add(row:inc(), nil, 0, nil, util.indent.virtual(util.table.border(true, { 5, 5 }), l2))
        marks
            :add(row:get(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), row:get(), 6, 7, util.table.pipe(true))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(true))
        marks
            :add(row:inc(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), row:get(), 0, 13, util.table.delimiter({ { 5 }, { 5 } }))

        marks
            :add(row:inc(), nil, 0, nil, border(1, 'above', false))
            :add(row:inc(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))
            :add(row:get(), nil, 0, nil, border(1, 'below', false))

        marks
            :add(row:inc(2), nil, 0, nil, util.indent.inline(l3))
            :add(row:get(), nil, 0, nil, border(3, 'above', false))
            :add(row:inc(), nil, 0, nil, util.heading.sign(3))
            :add(row:get(), nil, 0, nil, util.indent.inline(l3))
            :add(row:get(), row:get(), 0, 3, util.heading.icon(3))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(3))
            :add(row:get(), nil, 0, nil, util.indent.inline(l3))
            :add(row:get(), nil, 0, nil, border(3, 'below', false))

        marks:add(row:inc(), nil, 0, nil, util.indent.inline(l3))

        util.assert_view(marks, {
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

        local marks, row = util.marks(), util.row()

        local l1, l2 = { 1, 3 }, { 1, 3, 1, 3 }

        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(2))
            :add(row:get(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), row:get(), 0, 2, util.heading.icon(2))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(2))

        marks:add(row:get(), nil, 0, nil, util.indent.inline(l2))

        marks:add(row:inc(), nil, 0, nil, util.indent.virtual(util.table.border(true, { 5, 5 }), l2))
        marks
            :add(row:get(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), row:get(), 6, 7, util.table.pipe(true))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(true))
        marks
            :add(row:inc(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), row:get(), 0, 13, util.table.delimiter({ { 5 }, { 5 } }))

        marks:add(row:inc(), nil, 0, nil, util.indent.inline(l1))

        marks
            :add(row:inc(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), nil, 0, nil, util.indent.inline(l1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks:add(row:get(), nil, 0, nil, util.indent.inline(l1))

        marks:add(row:inc(), nil, 0, nil, util.indent.inline(l1))

        marks:add(row:inc(), nil, 0, nil, util.indent.inline(l1))
        marks:add(row:get(), nil, 0, nil, util.indent.inline(l2))

        marks
            :add(row:inc(), nil, 0, nil, util.heading.sign(3))
            :add(row:get(), nil, 0, nil, util.indent.inline(l1))
            :add(row:get(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), row:get(), 0, 3, util.heading.icon(3))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(3))

        marks:add(row:get(), nil, 0, nil, util.indent.inline(l1))
        marks:add(row:get(), nil, 0, nil, util.indent.inline(l2))

        marks:add(row:inc(), nil, 0, nil, util.indent.inline(l1))
        marks:add(row:get(), nil, 0, nil, util.indent.inline(l2))

        util.assert_view(marks, {
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
