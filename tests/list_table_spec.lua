---@module 'luassert'

local util = require('tests.util')

describe('list_table.md', function()
    it('default', function()
        util.setup('demo/list_table.md')

        local marks, row = util.marks(), util.row()

        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks:add(row:inc(), row:get(), 0, 2, util.bullet(1))
        marks:add(row:get(), row:get(), 20, 47, util.link('web'))
        marks:add(row:inc(), row:get(), 0, 2, util.bullet(1))
        marks:add(row:get(), row:get(), 20, 28, util.highlight('code'))
        marks:add(row:inc(), row:get(), 2, 6, util.bullet(2, 2))
        marks:add(row:inc(), row:get(), 4, 6, util.bullet(2))
        marks:add(row:inc(), row:get(), 6, 8, util.bullet(3))
        marks:add(row:inc(), row:get(), 8, 10, util.bullet(4))
        marks:add(row:inc(), row:get(), 10, 12, util.bullet(1))
        marks:add(row:inc(), row:get(), 0, 2, util.bullet(1))
        marks:add(row:get(), row:get(), 20, 45, util.link('link'))

        marks
            :add(row:inc(2), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks:add(row:inc(), row:get(), 0, 3, {
            virt_text = { { '1.', 'RmBullet' } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:inc(), row:get(), 0, 3, {
            virt_text = { { '2.', 'RmBullet' } },
            virt_text_pos = 'overlay',
        })

        marks
            :add(row:inc(2), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks:add(row:inc(), nil, 0, nil, util.table.border(true, { 8, 15, 7, 6 }))
        marks
            :add(row:get(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), row:get(), 2, 8, util.highlight('code'))
            :add(row:get(), nil, 9, nil, util.table.padding(2))
            :add(row:get(), row:get(), 9, 10, util.table.pipe(true))
            :add(row:get(), nil, 11, nil, util.table.padding(3))
            :add(row:get(), row:get(), 24, 25, util.conceal())
            :add(row:get(), row:get(), 25, 26, util.table.pipe(true))
            :add(row:get(), row:get(), 33, 34, util.table.pipe(true))
            :add(row:get(), row:get(), 40, 41, util.table.pipe(true))
        marks:add(row:inc(), row:get(), 0, 41, util.table.delimiter({ { 1, 7 }, { 1, 13, 1 }, { 6, 1 }, { 6 } }))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), row:get(), 2, 8, util.highlight('code'))
            :add(row:get(), nil, 9, nil, util.table.padding(2))
            :add(row:get(), row:get(), 9, 10, util.table.pipe(false))
            :add(row:get(), nil, 11, nil, util.table.padding(4))
            :add(row:get(), row:get(), 25, 26, util.table.pipe(false))
            :add(row:get(), row:get(), 33, 34, util.table.pipe(false))
            :add(row:get(), row:get(), 40, 41, util.table.pipe(false))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), row:get(), 9, 10, util.table.pipe(false))
            :add(row:get(), nil, 11, nil, util.table.padding(3))
            :add(row:get(), row:get(), 11, 24, util.link('link'))
            :add(row:get(), nil, 25, nil, util.table.padding(4))
            :add(row:get(), row:get(), 25, 26, util.table.pipe(false))
            :add(row:get(), nil, 27, nil, util.table.padding(1))
            :add(row:get(), row:get(), 32, 33, util.conceal())
            :add(row:get(), row:get(), 33, 34, util.table.pipe(false))
            :add(row:get(), row:get(), 40, 41, util.table.pipe(false))
        marks:add(row:get(), nil, 0, nil, util.table.border(false, { 8, 15, 7, 6 }))

        util.assert_view(marks, {
            '󰫎   1 󰲡 Unordered List',
            '    2',
            '    3 ● List Item 1: with 󰖟 link',
            '    4 ● List Item 2: with inline code',
            '    5     ○ Nested List 1 Item 1',
            '    6     ○ Nested List 1 Item 2',
            '    7       ◆ Nested List 2 Item 1',
            '    8         ◇ Nested List 3 Item 1',
            '    9           ● Nested List 4 Item 1',
            '   10 ● List Item 3: with 󰌹 reference link',
            '   11',
            '󰫎  12 󰲡 Ordered List',
            '   13',
            '   14 1. Item 1',
            '   15 2. Item 2',
            '   16',
            '󰫎  17 󰲡 Table',
            '   18',
            '      ┌────────┬───────────────┬───────┬──────┐',
            '   19 │ Left   │    Center     │ Right │ None │',
            '   20 ├━───────┼━─────────────━┼──────━┼──────┤',
            '   21 │ Code   │     Bold      │ Plain │ Item │',
            '   22 │ Item   │    󰌹 link     │  Item │ Item │',
            '      └────────┴───────────────┴───────┴──────┘',
            '   23',
            '   24 [example]: https://example.com',
        })
    end)

    it('padding', function()
        util.setup('demo/list_table.md', {
            code = { inline_pad = 2 },
            bullet = { left_pad = 2, right_pad = 2 },
        })

        local marks, row = util.marks(), util.row()

        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 0, 2, util.bullet(1))
            :add(row:get(), nil, 1, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 20, 47, util.link('web'))
        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 0, 2, util.bullet(1))
            :add(row:get(), nil, 1, nil, util.padding(2, 0))
            :add(row:get(), nil, 20, nil, util.code.padding(2))
            :add(row:get(), row:get(), 20, 28, util.highlight('code'))
            :add(row:get(), nil, 28, nil, util.code.padding(2))
        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 2, 6, util.bullet(2, 2))
            :add(row:get(), nil, 5, nil, util.padding(2, 0))
        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 4, 6, util.bullet(2))
            :add(row:get(), nil, 5, nil, util.padding(2, 0))
        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 6, 8, util.bullet(3))
            :add(row:get(), nil, 7, nil, util.padding(2, 0))
        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 8, 10, util.bullet(4))
            :add(row:get(), nil, 9, nil, util.padding(2, 0))
        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 10, 12, util.bullet(1))
            :add(row:get(), nil, 11, nil, util.padding(2, 0))
        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 0, 2, util.bullet(1))
            :add(row:get(), nil, 1, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 20, 45, util.link('link'))

        marks
            :add(row:inc(2), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 0, 3, {
                virt_text = { { '1.', 'RmBullet' } },
                virt_text_pos = 'overlay',
            })
            :add(row:get(), nil, 2, nil, util.padding(2, 0))
        marks
            :add(row:inc(), nil, 0, nil, util.padding(2, 0))
            :add(row:get(), row:get(), 0, 3, {
                virt_text = { { '2.', 'RmBullet' } },
                virt_text_pos = 'overlay',
            })
            :add(row:get(), nil, 2, nil, util.padding(2, 0))

        marks
            :add(row:inc(2), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks:add(row:inc(), nil, 0, nil, util.table.border(true, { 10, 15, 7, 6 }))
        marks
            :add(row:get(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), nil, 2, nil, util.code.padding(2))
            :add(row:get(), row:get(), 2, 8, util.highlight('code'))
            :add(row:get(), nil, 8, nil, util.code.padding(2))
            :add(row:get(), row:get(), 9, 10, util.table.pipe(true))
            :add(row:get(), nil, 11, nil, util.table.padding(3))
            :add(row:get(), row:get(), 24, 25, util.conceal())
            :add(row:get(), row:get(), 25, 26, util.table.pipe(true))
            :add(row:get(), row:get(), 33, 34, util.table.pipe(true))
            :add(row:get(), row:get(), 40, 41, util.table.pipe(true))
        marks:add(row:inc(), row:get(), 0, 41, util.table.delimiter({ { 1, 9 }, { 1, 13, 1 }, { 6, 1 }, { 6 } }))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), nil, 2, nil, util.code.padding(2))
            :add(row:get(), row:get(), 2, 8, util.highlight('code'))
            :add(row:get(), nil, 8, nil, util.code.padding(2))
            :add(row:get(), row:get(), 9, 10, util.table.pipe(false))
            :add(row:get(), nil, 11, nil, util.table.padding(4))
            :add(row:get(), row:get(), 25, 26, util.table.pipe(false))
            :add(row:get(), row:get(), 33, 34, util.table.pipe(false))
            :add(row:get(), row:get(), 40, 41, util.table.pipe(false))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), nil, 9, nil, util.table.padding(2))
            :add(row:get(), row:get(), 9, 10, util.table.pipe(false))
            :add(row:get(), nil, 11, nil, util.table.padding(3))
            :add(row:get(), row:get(), 11, 24, util.link('link'))
            :add(row:get(), nil, 25, nil, util.table.padding(4))
            :add(row:get(), row:get(), 25, 26, util.table.pipe(false))
            :add(row:get(), nil, 27, nil, util.table.padding(1))
            :add(row:get(), row:get(), 32, 33, util.conceal())
            :add(row:get(), row:get(), 33, 34, util.table.pipe(false))
            :add(row:get(), row:get(), 40, 41, util.table.pipe(false))
        marks:add(row:get(), nil, 0, nil, util.table.border(false, { 10, 15, 7, 6 }))

        util.assert_view(marks, {
            '󰫎   1 󰲡 Unordered List',
            '    2',
            '    3   ●   List Item 1: with 󰖟 link',
            '    4   ●   List Item 2: with   inline   code',
            '    5       ○   Nested List 1 Item 1',
            '    6       ○   Nested List 1 Item 2',
            '    7         ◆   Nested List 2 Item 1',
            '    8           ◇   Nested List 3 Item 1',
            '    9             ●   Nested List 4 Item 1',
            '   10   ●   List Item 3: with 󰌹 reference link',
            '   11',
            '󰫎  12 󰲡 Ordered List',
            '   13',
            '   14   1.   Item 1',
            '   15   2.   Item 2',
            '   16',
            '󰫎  17 󰲡 Table',
            '   18',
            '      ┌──────────┬───────────────┬───────┬──────┐',
            '   19 │   Left   │    Center     │ Right │ None │',
            '   20 ├━─────────┼━─────────────━┼──────━┼──────┤',
            '   21 │   Code   │     Bold      │ Plain │ Item │',
            '   22 │ Item     │    󰌹 link     │  Item │ Item │',
            '      └──────────┴───────────────┴───────┴──────┘',
            '   23',
            '   24 [example]: https://example.com',
        })
    end)
end)
