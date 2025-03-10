---@module 'luassert'

local util = require('tests.util')

describe('list_table.md', function()
    it('default', function()
        util.setup('demo/list_table.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.link(row:get(), 20, 47, 'web'),
            util.bullet(row:increment(), 0, 1),
            util.highlight(row:get(), 20, 28, 'CodeInline'),
            util.bullet(row:increment(), 2, 2, 2),
            util.bullet(row:increment(), 4, 2),
            util.bullet(row:increment(), 6, 3),
            util.bullet(row:increment(), 8, 4),
            util.bullet(row:increment(), 10, 1),
            util.bullet(row:increment(), 0, 1),
            util.link(row:get(), 20, 45, 'link'),
        })

        vim.list_extend(expected, util.heading(row:increment(2), 1))

        vim.list_extend(expected, {
            util.ordered(row:increment(2), 0, '1.'),
            util.ordered(row:increment(1), 0, '2.'),
        })

        vim.list_extend(expected, util.heading(row:increment(2), 1))

        vim.list_extend(expected, {
            util.table_border(row:increment(2), true, { 8, 15, 7, 6 }),
            util.table_pipe(row:get(), 0, true),
            util.highlight(row:get(), 2, 8, 'CodeInline'),
            util.padding(row:get(), 9, 2, 'table'),
            util.table_pipe(row:get(), 9, true),
            util.padding(row:get(), 11, 3, 'table'),
            util.conceal(row:get(), 24, 25),
            util.table_pipe(row:get(), 25, true),
            util.table_pipe(row:get(), 33, true),
            util.table_pipe(row:get(), 40, true),
        })
        table.insert(expected, util.table_delimiter(row:increment(), { { 1, 7 }, { 1, 13, 1 }, { 6, 1 }, 6 }))
        vim.list_extend(expected, {
            util.table_pipe(row:increment(), 0, false),
            util.highlight(row:get(), 2, 8, 'CodeInline'),
            util.padding(row:get(), 9, 2, 'table'),
            util.table_pipe(row:get(), 9, false),
            util.padding(row:get(), 11, 4, 'table'),
            util.table_pipe(row:get(), 25, false),
            util.table_pipe(row:get(), 33, false),
            util.table_pipe(row:get(), 40, false),
        })
        vim.list_extend(expected, {
            util.table_pipe(row:increment(), 0, false),
            util.table_pipe(row:get(), 9, false),
            util.padding(row:get(), 11, 3, 'table'),
            util.link(row:get(), 11, 24, 'link'),
            util.padding(row:get(), 25, 4, 'table'),
            util.table_pipe(row:get(), 25, false),
            util.padding(row:get(), 27, 1, 'table'),
            util.conceal(row:get(), 32, 33),
            util.table_pipe(row:get(), 33, false),
            util.table_pipe(row:get(), 40, false),
            util.table_border(row:get(), false, { 8, 15, 7, 6 }),
        })

        util.assert_view(expected, {
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

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, {
            util.padding(row:increment(2), 0, 2),
            util.bullet(row:get(), 0, 1),
            util.padding(row:get(), 1, 2),
            util.link(row:get(), 20, 47, 'web'),

            util.padding(row:increment(), 0, 2),
            util.bullet(row:get(), 0, 1),
            util.padding(row:get(), 1, 2),
            util.padding(row:get(), 20, 2, 'code'),
            util.highlight(row:get(), 20, 28, 'CodeInline'),
            util.padding(row:get(), 28, 2, 'code'),

            util.padding(row:increment(), 0, 2),
            util.bullet(row:get(), 2, 2, 2),
            util.padding(row:get(), 5, 2),

            util.padding(row:increment(), 0, 2),
            util.bullet(row:get(), 4, 2),
            util.padding(row:get(), 5, 2),

            util.padding(row:increment(), 0, 2),
            util.bullet(row:get(), 6, 3),
            util.padding(row:get(), 7, 2),

            util.padding(row:increment(), 0, 2),
            util.bullet(row:get(), 8, 4),
            util.padding(row:get(), 9, 2),

            util.padding(row:increment(), 0, 2),
            util.bullet(row:get(), 10, 1),
            util.padding(row:get(), 11, 2),

            util.padding(row:increment(), 0, 2),
            util.bullet(row:get(), 0, 1),
            util.padding(row:get(), 1, 2),
            util.link(row:get(), 20, 45, 'link'),
        })

        vim.list_extend(expected, util.heading(row:increment(2), 1))

        vim.list_extend(expected, {
            util.padding(row:increment(2), 0, 2),
            util.ordered(row:get(), 0, '1.'),
            util.padding(row:get(), 2, 2),

            util.padding(row:increment(), 0, 2),
            util.ordered(row:get(), 0, '2.'),
            util.padding(row:get(), 2, 2),
        })

        vim.list_extend(expected, util.heading(row:increment(2), 1))

        vim.list_extend(expected, {
            util.table_border(row:increment(2), true, { 10, 15, 7, 6 }),
            util.table_pipe(row:get(), 0, true),
            util.padding(row:get(), 2, 2, 'code'),
            util.highlight(row:get(), 2, 8, 'CodeInline'),
            util.padding(row:get(), 8, 2, 'code'),
            util.table_pipe(row:get(), 9, true),
            util.padding(row:get(), 11, 3, 'table'),
            util.conceal(row:get(), 24, 25),
            util.table_pipe(row:get(), 25, true),
            util.table_pipe(row:get(), 33, true),
            util.table_pipe(row:get(), 40, true),
        })
        table.insert(expected, util.table_delimiter(row:increment(), { { 1, 9 }, { 1, 13, 1 }, { 6, 1 }, 6 }, nil, 2))
        vim.list_extend(expected, {
            util.table_pipe(row:increment(), 0, false),
            util.padding(row:get(), 2, 2, 'code'),
            util.highlight(row:get(), 2, 8, 'CodeInline'),
            util.padding(row:get(), 8, 2, 'code'),
            util.table_pipe(row:get(), 9, false),
            util.padding(row:get(), 11, 4, 'table'),
            util.table_pipe(row:get(), 25, false),
            util.table_pipe(row:get(), 33, false),
            util.table_pipe(row:get(), 40, false),
        })
        vim.list_extend(expected, {
            util.table_pipe(row:increment(), 0, false),
            util.padding(row:get(), 9, 2, 'table'),
            util.table_pipe(row:get(), 9, false),
            util.padding(row:get(), 11, 3, 'table'),
            util.link(row:get(), 11, 24, 'link'),
            util.padding(row:get(), 25, 4, 'table'),
            util.table_pipe(row:get(), 25, false),
            util.padding(row:get(), 27, 1, 'table'),
            util.conceal(row:get(), 32, 33),
            util.table_pipe(row:get(), 33, false),
            util.table_pipe(row:get(), 40, false),
            util.table_border(row:get(), false, { 10, 15, 7, 6 }),
        })

        util.assert_view(expected, {
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
