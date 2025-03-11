---@module 'luassert'

local util = require('tests.util')

---@param mark render.md.test.MarkInfo
---@return render.md.test.MarkInfo[]
local function padded(mark)
    local col = mark.col[2]
    assert(col ~= nil)
    return {
        util.padding(mark.row[1], 0, 2),
        mark,
        util.padding(mark.row[1], col - 1, 2),
    }
end

describe('list_table.md', function()
    it('default', function()
        util.setup('demo/list_table.md')

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        marks:add(util.bullet(row:inc(2), 0, 1))
        marks:add(util.link(row:get(), { 20, 47 }, 'web'))
        marks:add(util.bullet(row:inc(), 0, 1))
        marks:add(util.highlight(row:get(), { 20, 28 }, 'code'))
        marks:add(util.bullet(row:inc(), 2, 2, 2))
        marks:add(util.bullet(row:inc(), 4, 2))
        marks:add(util.bullet(row:inc(), 6, 3))
        marks:add(util.bullet(row:inc(), 8, 4))
        marks:add(util.bullet(row:inc(), 10, 1))
        marks:add(util.bullet(row:inc(), 0, 1))
        marks:add(util.link(row:get(), { 20, 45 }, 'link'))

        marks:extend(util.heading(row:inc(2), 1))

        marks:add(util.ordered(row:inc(2), 0, '1.'))
        marks:add(util.ordered(row:inc(), 0, '2.'))

        marks:extend(util.heading(row:inc(2), 1))

        marks:add(util.table_border(row:inc(2), true, { 8, 15, 7, 6 }))
        marks:add(util.table_pipe(row:get(), 0, true))
        marks:add(util.highlight(row:get(), { 2, 8 }, 'code'))
        marks:add(util.padding(row:get(), 9, 2, 'table'))
        marks:add(util.table_pipe(row:get(), 9, true))
        marks:add(util.padding(row:get(), 11, 3, 'table'))
        marks:add(util.conceal(row:get(), { 24, 25 }))
        marks:add(util.table_pipe(row:get(), 25, true))
        marks:add(util.table_pipe(row:get(), 33, true))
        marks:add(util.table_pipe(row:get(), 40, true))
        marks:add(util.table_delimiter(row:inc(), 41, { { 1, 7 }, { 1, 13, 1 }, { 6, 1 }, 6 }))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.highlight(row:get(), { 2, 8 }, 'code'))
        marks:add(util.padding(row:get(), 9, 2, 'table'))
        marks:add(util.table_pipe(row:get(), 9, false))
        marks:add(util.padding(row:get(), 11, 4, 'table'))
        marks:add(util.table_pipe(row:get(), 25, false))
        marks:add(util.table_pipe(row:get(), 33, false))
        marks:add(util.table_pipe(row:get(), 40, false))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.table_pipe(row:get(), 9, false))
        marks:add(util.padding(row:get(), 11, 3, 'table'))
        marks:add(util.link(row:get(), { 11, 24 }, 'link'))
        marks:add(util.padding(row:get(), 25, 4, 'table'))
        marks:add(util.table_pipe(row:get(), 25, false))
        marks:add(util.padding(row:get(), 27, 1, 'table'))
        marks:add(util.conceal(row:get(), { 32, 33 }))
        marks:add(util.table_pipe(row:get(), 33, false))
        marks:add(util.table_pipe(row:get(), 40, false))
        marks:add(util.table_border(row:get(), false, { 8, 15, 7, 6 }))

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

        marks:extend(util.heading(row:get(), 1))

        marks:extend(padded(util.bullet(row:inc(2), 0, 1)))
        marks:add(util.link(row:get(), { 20, 47 }, 'web'))
        marks:extend(padded(util.bullet(row:inc(), 0, 1)))
        marks:add(util.padding(row:get(), 20, 2, 'code'))
        marks:add(util.highlight(row:get(), { 20, 28 }, 'code'))
        marks:add(util.padding(row:get(), 28, 2, 'code'))
        marks:extend(padded(util.bullet(row:inc(), 2, 2, 2)))
        marks:extend(padded(util.bullet(row:inc(), 4, 2)))
        marks:extend(padded(util.bullet(row:inc(), 6, 3)))
        marks:extend(padded(util.bullet(row:inc(), 8, 4)))
        marks:extend(padded(util.bullet(row:inc(), 10, 1)))
        marks:extend(padded(util.bullet(row:inc(), 0, 1)))
        marks:add(util.link(row:get(), { 20, 45 }, 'link'))

        marks:extend(util.heading(row:inc(2), 1))

        marks:extend(padded(util.ordered(row:inc(2), 0, '1.')))
        marks:extend(padded(util.ordered(row:inc(), 0, '2.')))

        marks:extend(util.heading(row:inc(2), 1))

        marks:add(util.table_border(row:inc(2), true, { 10, 15, 7, 6 }))
        marks:add(util.table_pipe(row:get(), 0, true))
        marks:add(util.padding(row:get(), 2, 2, 'code'))
        marks:add(util.highlight(row:get(), { 2, 8 }, 'code'))
        marks:add(util.padding(row:get(), 8, 2, 'code'))
        marks:add(util.table_pipe(row:get(), 9, true))
        marks:add(util.padding(row:get(), 11, 3, 'table'))
        marks:add(util.conceal(row:get(), { 24, 25 }))
        marks:add(util.table_pipe(row:get(), 25, true))
        marks:add(util.table_pipe(row:get(), 33, true))
        marks:add(util.table_pipe(row:get(), 40, true))
        marks:add(util.table_delimiter(row:inc(), 41, { { 1, 9 }, { 1, 13, 1 }, { 6, 1 }, 6 }))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.padding(row:get(), 2, 2, 'code'))
        marks:add(util.highlight(row:get(), { 2, 8 }, 'code'))
        marks:add(util.padding(row:get(), 8, 2, 'code'))
        marks:add(util.table_pipe(row:get(), 9, false))
        marks:add(util.padding(row:get(), 11, 4, 'table'))
        marks:add(util.table_pipe(row:get(), 25, false))
        marks:add(util.table_pipe(row:get(), 33, false))
        marks:add(util.table_pipe(row:get(), 40, false))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.padding(row:get(), 9, 2, 'table'))
        marks:add(util.table_pipe(row:get(), 9, false))
        marks:add(util.padding(row:get(), 11, 3, 'table'))
        marks:add(util.link(row:get(), { 11, 24 }, 'link'))
        marks:add(util.padding(row:get(), 25, 4, 'table'))
        marks:add(util.table_pipe(row:get(), 25, false))
        marks:add(util.padding(row:get(), 27, 1, 'table'))
        marks:add(util.conceal(row:get(), { 32, 33 }))
        marks:add(util.table_pipe(row:get(), 33, false))
        marks:add(util.table_pipe(row:get(), 40, false))
        marks:add(util.table_border(row:get(), false, { 10, 15, 7, 6 }))

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
