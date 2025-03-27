---@module 'luassert'

local util = require('tests.util')

---@param level integer
---@param position 'above'|'below'
---@return vim.api.keyset.set_extmark
local function border(level, position)
    local icon = position == 'above' and '▄' or '▀'
    local background = string.format('Rm_bgtofg_RmH%dBg', level)
    ---@type vim.api.keyset.set_extmark
    return {
        virt_text = { { icon:rep(vim.o.columns), background } },
        virt_text_pos = 'overlay',
    }
end

describe('indent', function()
    local lines = {
        '',
        '## Heading 2',
        '',
        '| Foo | Bar |',
        '| --- | --- |',
        '',
        '# Heading 1',
        '',
        'Foo',
        '',
        '### Heading 3',
        '',
        'Bar',
    }

    it('with heading border & no icon', function()
        util.setup.text(lines, {
            heading = { border = true },
            indent = { enabled = true, icon = '' },
        })

        local marks, row = util.marks(), util.row()

        local l2, l3 = { 2 }, { 4 }

        marks
            :add(row:get(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), nil, 0, nil, border(2, 'above'))
            :add(row:inc(), nil, 0, nil, util.heading.sign(2))
            :add(row:get(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), row:get(), 0, 2, util.heading.icon(2))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(2))
            :add(row:get(), nil, 0, nil, util.indent.inline(l2))
            :add(row:get(), nil, 0, nil, border(2, 'below'))

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
            :add(row:inc(), nil, 0, nil, border(1, 'above'))
            :add(row:inc(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))
            :add(row:get(), nil, 0, nil, border(1, 'below'))

        marks
            :add(row:inc(2), nil, 0, nil, util.indent.inline(l3))
            :add(row:get(), nil, 0, nil, border(3, 'above'))
            :add(row:inc(), nil, 0, nil, util.heading.sign(3))
            :add(row:get(), nil, 0, nil, util.indent.inline(l3))
            :add(row:get(), row:get(), 0, 3, util.heading.icon(3))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(3))
            :add(row:get(), nil, 0, nil, util.indent.inline(l3))
            :add(row:get(), nil, 0, nil, border(3, 'below'))

        marks:add(row:inc(), nil, 0, nil, util.indent.inline(l3))

        util.assert_view(marks, {
            '    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎    󰲣 Heading 2',
            '    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '    ┌─────┬─────┐',
            '    │ Foo │ Bar │',
            '    ├─────┼─────┤',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎 󰲡 Heading 1',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  Foo',
            '      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎       󰲥 Heading 3',
            '      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '      Bar',
        })
    end)

    it('with per_level & skip_level', function()
        util.setup.text(lines, {
            indent = { enabled = true, per_level = 4, skip_level = 0 },
        })

        local marks, row = util.marks(), util.row()

        local l1, l2 = { 1, 3 }, { 1, 3, 1, 3 }

        marks
            :add(row:get(), nil, 0, nil, util.indent.inline(l2))
            :add(row:inc(), nil, 0, nil, util.heading.sign(2))
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
            '  ▎   ▎',
            '󰫎 ▎   ▎    󰲣 Heading 2',
            '  ▎   ▎',
            '  ▎   ▎   ┌─────┬─────┐',
            '  ▎   ▎   │ Foo │ Bar │',
            '  ▎   ▎   ├─────┼─────┤',
            '  ▎',
            '󰫎 ▎   󰲡 Heading 1',
            '  ▎',
            '  ▎   Foo',
            '  ▎   ▎   ▎',
            '󰫎 ▎   ▎   ▎     󰲥 Heading 3',
            '  ▎   ▎   ▎',
            '  ▎   ▎   ▎   Bar',
        })
    end)
end)
