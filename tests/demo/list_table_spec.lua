---@module 'luassert'

local util = require('tests.util')

---@return render.md.test.Marks
local function shared()
    local marks, row = util.marks(), util.row()

    marks:add(row:get(0), 0, util.heading.sign(1))
    marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
    marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

    marks:add(row:get(1, 0), { 0, 2 }, util.bullet(1))
    marks:add(row:get(0), 20, util.link('web'))
    marks:add(row:get(1, 0), { 0, 2 }, util.bullet(1))
    marks:add(row:get(0, 0), { 20, 28 }, util.highlight('code'))
    marks:add(row:get(1, 0), { 2, 6 }, util.bullet(2, 2))
    marks:add(row:get(1, 0), { 4, 6 }, util.bullet(2))
    marks:add(row:get(1, 0), { 6, 8 }, util.bullet(3))
    marks:add(row:get(1, 0), { 8, 10 }, util.bullet(4))
    marks:add(row:get(1, 0), { 10, 12 }, util.bullet(1))
    marks:add(row:get(1, 0), { 0, 2 }, util.bullet(1))
    marks:add(row:get(0), 20, util.link('link'))

    marks:add(row:get(2), 0, util.heading.sign(1))
    marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
    marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

    marks:add(row:get(1, 0), { 0, 3 }, util.ordered(1))
    marks:add(row:get(1, 0), { 0, 3 }, util.ordered(2))

    marks:add(row:get(2), 0, util.heading.sign(1))
    marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
    marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

    marks:add(row:get(1, 0), { 0, 1 }, util.table.pipe(true))
    marks:add(row:get(0, 0), { 2, 8 }, util.highlight('code'))
    marks:add(row:get(0, 0), { 9, 10 }, util.table.pipe(true))
    marks:add(row:get(0), 11, util.table.padding(3))
    marks:add(row:get(0, 0), { 24, 25 }, util.conceal())
    marks:add(row:get(0, 0), { 25, 26 }, util.table.pipe(true))
    marks:add(row:get(0, 0), { 33, 34 }, util.table.pipe(true))
    marks:add(row:get(0, 0), { 40, 41 }, util.table.pipe(true))
    marks:add(row:get(2, 0), { 0, 1 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 2, 8 }, util.highlight('code'))
    marks:add(row:get(0, 0), { 9, 10 }, util.table.pipe(false))
    marks:add(row:get(0), 11, util.table.padding(4))
    marks:add(row:get(0, 0), { 25, 26 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 33, 34 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 40, 41 }, util.table.pipe(false))
    marks:add(row:get(1, 0), { 0, 1 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 9, 10 }, util.table.pipe(false))
    marks:add(row:get(0), 11, util.table.padding(3))
    marks:add(row:get(0), 11, util.link('link'))
    marks:add(row:get(0), 25, util.table.padding(4))
    marks:add(row:get(0, 0), { 25, 26 }, util.table.pipe(false))
    marks:add(row:get(0), 27, util.table.padding(1))
    marks:add(row:get(0, 0), { 32, 33 }, util.conceal())
    marks:add(row:get(0, 0), { 33, 34 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 40, 41 }, util.table.pipe(false))

    return marks
end

describe('demo/list_table.md', function()
    it('default', function()
        util.setup.file('demo/list_table.md')

        local marks, row = shared(), util.row()

        marks:add(row:get(17), 0, util.table.border(false, true, 8, 15, 7, 6))
        marks:add(row:get(1), 9, util.table.padding(2))
        marks:add(
            row:get(1, 0),
            { 0, 41 },
            util.table.delimiter(0, { 1, 7 }, { 1, 13, 1 }, { 6, 1 }, { 6 })
        )
        marks:add(row:get(1), 9, util.table.padding(2))
        marks:add(row:get(2), 0, util.table.border(false, false, 8, 15, 7, 6))

        util.assert_view(marks, {
            '󰫎 󰲡 Unordered List',
            '',
            '  ● List Item 1: with 󰖟 link',
            '  ● List Item 2: with inline code',
            '      ○ Nested List 1 Item 1',
            '      ○ Nested List 1 Item 2',
            '        ◆ Nested List 2 Item 1',
            '          ◇ Nested List 3 Item 1',
            '            ● Nested List 4 Item 1',
            '  ● List Item 3: with 󰌹 reference link',
            '',
            '󰫎 󰲡 Ordered List',
            '',
            '  1. Item 1',
            '  2. Item 2',
            '',
            '󰫎 󰲡 Table',
            '  ┌────────┬───────────────┬───────┬──────┐',
            '  │ Left   │    Center     │ Right │ None │',
            '  ├━───────┼━─────────────━┼──────━┼──────┤',
            '  │ Code   │     Bold      │ Plain │ Item │',
            '  │ Item   │    󰌹 link     │  Item │ Item │',
            '  └────────┴───────────────┴───────┴──────┘',
            '  [example]: https://example.com',
        })
    end)

    it('padding', function()
        util.setup.file('demo/list_table.md', {
            code = { inline_pad = 2 },
            bullet = { left_pad = 2, right_pad = 2 },
        })

        local marks, row = shared(), util.row()

        marks:add(row:get(2), 0, util.padding(2))
        marks:add(row:get(0), 1, util.padding(2))
        marks:add(row:get(1), 0, util.padding(2))
        marks:add(row:get(0), 1, util.padding(2))
        marks:add(row:get(0), 20, util.code.padding('inline', 2))
        marks:add(row:get(0), 28, util.code.padding('inline', 2))
        marks:add(row:get(1), 0, util.padding(2))
        marks:add(row:get(0), 5, util.padding(2))
        marks:add(row:get(1), 0, util.padding(2))
        marks:add(row:get(0), 5, util.padding(2))
        marks:add(row:get(1), 0, util.padding(2))
        marks:add(row:get(0), 7, util.padding(2))
        marks:add(row:get(1), 0, util.padding(2))
        marks:add(row:get(0), 9, util.padding(2))
        marks:add(row:get(1), 0, util.padding(2))
        marks:add(row:get(0), 11, util.padding(2))
        marks:add(row:get(1), 0, util.padding(2))
        marks:add(row:get(0), 1, util.padding(2))

        marks:add(row:get(4), 0, util.padding(2))
        marks:add(row:get(0), 2, util.padding(2))
        marks:add(row:get(1), 0, util.padding(2))
        marks:add(row:get(0), 2, util.padding(2))

        marks:add(row:get(3), 0, util.table.border(false, true, 10, 15, 7, 6))
        marks:add(row:get(1), 2, util.code.padding('inline', 2))
        marks:add(row:get(0), 8, util.code.padding('inline', 2))
        marks:add(
            row:get(1, 0),
            { 0, 41 },
            util.table.delimiter(0, { 1, 9 }, { 1, 13, 1 }, { 6, 1 }, { 6 })
        )
        marks:add(row:get(1), 2, util.code.padding('inline', 2))
        marks:add(row:get(0), 8, util.code.padding('inline', 2))
        marks:add(row:get(1), 9, util.table.padding(2))
        marks:add(row:get(1), 0, util.table.border(false, false, 10, 15, 7, 6))

        util.assert_view(marks, {
            '󰫎 󰲡 Unordered List',
            '',
            '    ●   List Item 1: with 󰖟 link',
            '    ●   List Item 2: with   inline   code',
            '        ○   Nested List 1 Item 1',
            '        ○   Nested List 1 Item 2',
            '          ◆   Nested List 2 Item 1',
            '            ◇   Nested List 3 Item 1',
            '              ●   Nested List 4 Item 1',
            '    ●   List Item 3: with 󰌹 reference link',
            '',
            '󰫎 󰲡 Ordered List',
            '',
            '    1.   Item 1',
            '    2.   Item 2',
            '',
            '󰫎 󰲡 Table',
            '  ┌──────────┬───────────────┬───────┬──────┐',
            '  │   Left   │    Center     │ Right │ None │',
            '  ├━─────────┼━─────────────━┼──────━┼──────┤',
            '  │   Code   │     Bold      │ Plain │ Item │',
            '  │ Item     │    󰌹 link     │  Item │ Item │',
            '  └──────────┴───────────────┴───────┴──────┘',
            '  [example]: https://example.com',
        })
    end)
end)
