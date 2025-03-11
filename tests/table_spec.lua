---@module 'luassert'

local util = require('tests.util')

describe('table.md', function()
    it('default', function()
        util.setup('tests/data/table.md')

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        marks:add(util.table_border(row:inc(2), true, { 11, 24 }))
        marks:add(util.table_pipe(row:get(), 0, true))
        marks:add(util.table_pipe(row:get(), 12, true))
        marks:add(util.padding(row:get(), 14, 13, 'table'))
        marks:add(util.highlight(row:get(), { 14, 25 }, 'code'))
        marks:add(util.conceal(row:get(), { 26, 37 }))
        marks:add(util.table_pipe(row:get(), 37, true))
        marks:add(util.table_delimiter(row:inc(), 38, { 11, { 23, 1 } }))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.highlight(row:get(), { 2, 12 }, 'code'))
        marks:add(util.padding(row:get(), 13, 2, 'table'))
        marks:add(util.table_pipe(row:get(), 13, false))
        marks:add(util.padding(row:get(), 15, 16, 'table'))
        marks:add(util.link(row:get(), { 15, 38 }, 'web'))
        marks:add(util.table_pipe(row:get(), 39, false))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.padding(row:get(), 12, 8, 'table'))
        marks:add(util.table_pipe(row:get(), 12, false))
        marks:add(util.padding(row:get(), 14, 16, 'table'))
        marks:extend(util.inline_highlight(row:get(), 14, 25))
        marks:add(util.conceal(row:get(), { 26, 38 }))
        marks:add(util.table_pipe(row:get(), 38, false))
        marks:add(util.table_border(row:get(), false, { 11, 24 }))

        marks:extend(util.heading(row:inc(2), 1))

        marks:add(util.table_border(row:inc(2), true, { 11, 11 }))
        marks:add(util.table_pipe(row:get(), 0, true))
        marks:add(util.table_pipe(row:get(), 12, true))
        marks:add(util.table_pipe(row:get(), 24, true))
        marks:add(util.table_delimiter(row:inc(), 25, { 11, 11 }))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.table_pipe(row:get(), 12, false))
        marks:add(util.table_pipe(row:get(), 24, false))
        marks:add(util.table_border(row:get(), false, { 11, 11 }))

        util.assert_view(marks, {
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬────────────────────────┐',
            '    3 │ Heading 1 │              Heading 2 │',
            '    4 ├───────────┼───────────────────────━┤',
            '    5 │ Item 行   │                 󰖟 link │',
            '    6 │ 1         │                 Itém 2 │',
            '      └───────────┴────────────────────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)

    it('trimmed', function()
        util.setup('tests/data/table.md', {
            pipe_table = { cell = 'trimmed' },
        })

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        marks:add(util.table_border(row:inc(2), true, { 11, 11 }))
        marks:add(util.table_pipe(row:get(), 0, true))
        marks:add(util.table_pipe(row:get(), 12, true))
        marks:add(util.highlight(row:get(), { 14, 25 }, 'code'))
        marks:add(util.conceal(row:get(), { 26, 37 }))
        marks:add(util.table_pipe(row:get(), 37, true))
        marks:add(util.table_delimiter(row:inc(), 38, { 11, { 10, 1 } }))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.highlight(row:get(), { 2, 12 }, 'code'))
        marks:add(util.padding(row:get(), 13, 2, 'table'))
        marks:add(util.table_pipe(row:get(), 13, false))
        marks:add(util.padding(row:get(), 15, 3, 'table'))
        marks:add(util.link(row:get(), { 15, 38 }, 'web'))
        marks:add(util.table_pipe(row:get(), 39, false))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.padding(row:get(), 12, 8, 'table'))
        marks:add(util.table_pipe(row:get(), 12, false))
        marks:add(util.padding(row:get(), 14, 3, 'table'))
        marks:extend(util.inline_highlight(row:get(), 14, 25))
        marks:add(util.conceal(row:get(), { 26, 38 }))
        marks:add(util.table_pipe(row:get(), 38, false))
        marks:add(util.table_border(row:get(), false, { 11, 11 }))

        marks:extend(util.heading(row:inc(2), 1))

        marks:add(util.table_border(row:inc(2), true, { 11, 11 }))
        marks:add(util.table_pipe(row:get(), 0, true))
        marks:add(util.table_pipe(row:get(), 12, true))
        marks:add(util.table_pipe(row:get(), 24, true))
        marks:add(util.table_delimiter(row:inc(), 25, { 11, 11 }))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.table_pipe(row:get(), 12, false))
        marks:add(util.table_pipe(row:get(), 24, false))
        marks:add(util.table_border(row:get(), false, { 11, 11 }))

        util.assert_view(marks, {
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬───────────┐',
            '    3 │ Heading 1 │ Heading 2 │',
            '    4 ├───────────┼──────────━┤',
            '    5 │ Item 行   │    󰖟 link │',
            '    6 │ 1         │    Itém 2 │',
            '      └───────────┴───────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)

    it('raw', function()
        util.setup('tests/data/table.md', {
            pipe_table = { cell = 'raw' },
        })

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        marks:add(util.table_pipe(row:inc(2), 0, true))
        marks:add(util.table_pipe(row:get(), 12, true))
        marks:add(util.highlight(row:get(), { 14, 25 }, 'code'))
        marks:add(util.table_pipe(row:get(), 37, true))
        marks:add(util.table_delimiter(row:inc(), 38, { 11, { 23, 1 } }))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.highlight(row:get(), { 2, 12 }, 'code'))
        marks:add(util.table_pipe(row:get(), 13, false))
        marks:add(util.link(row:get(), { 15, 38 }, 'web'))
        marks:add(util.table_pipe(row:get(), 39, false))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.table_pipe(row:get(), 12, false))
        marks:extend(util.inline_highlight(row:get(), 14, 25))
        marks:add(util.table_pipe(row:get(), 38, false))

        marks:extend(util.heading(row:inc(2), 1))

        marks:add(util.table_border(row:inc(2), true, { 11, 11 }))
        marks:add(util.table_pipe(row:get(), 0, true))
        marks:add(util.table_pipe(row:get(), 12, true))
        marks:add(util.table_pipe(row:get(), 24, true))
        marks:add(util.table_delimiter(row:inc(), 25, { 11, 11 }))
        marks:add(util.table_pipe(row:inc(), 0, false))
        marks:add(util.table_pipe(row:get(), 12, false))
        marks:add(util.table_pipe(row:get(), 24, false))
        marks:add(util.table_border(row:get(), false, { 11, 11 }))

        util.assert_view(marks, {
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '    3 │ Heading 1 │ Heading 2            │',
            '    4 ├───────────┼───────────────────────━┤',
            '    5 │ Item 行 │ 󰖟 link │',
            '    6 │ 1 │ Itém 2             │',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)

    it('overlay', function()
        util.setup('tests/data/table.md', {
            pipe_table = { cell = 'overlay' },
        })

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        marks:add(util.table_border(row:inc(2), true, { 11, 24 }))
        marks:add(util.overlay(row:get(), { 0, 38 }, { '│ Heading 1 │ `Heading 2`            │', 'RmTableHead' }))
        marks:add(util.highlight(row:get(), { 14, 25 }, 'code'))
        marks:add(util.table_delimiter(row:inc(), 38, { 11, { 23, 1 } }))
        marks:add(
            util.overlay(row:inc(), { 0, 40 }, { '│ `Item 行` │ [link](https://行.com) │', 'RmTableRow' })
        )
        marks:add(util.highlight(row:get(), { 2, 12 }, 'code'))
        marks:add(util.link(row:get(), { 15, 38 }, 'web'))
        marks:add(util.overlay(row:inc(), { 0, 39 }, { '│ &lt;1&gt; │ ==Itém 2==             │', 'RmTableRow' }))
        marks:extend(util.inline_highlight(row:get(), 14, 25))
        marks:add(util.table_border(row:get(), false, { 11, 24 }))

        marks:extend(util.heading(row:inc(2), 1))

        marks:add(util.table_border(row:inc(2), true, { 11, 11 }))
        marks:add(util.overlay(row:get(), { 0, 25 }, { '│ Heading 1 │ Heading 2 │', 'RmTableHead' }))
        marks:add(util.table_delimiter(row:inc(), 25, { 11, 11 }))
        marks:add(util.overlay(row:inc(), { 0, 25 }, { '│ Item 1    │ Item 2    │', 'RmTableRow' }))
        marks:add(util.table_border(row:get(), false, { 11, 11 }))

        util.assert_view(marks, {
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬────────────────────────┐',
            '    3 │ Heading 1 │ `Heading 2`            │',
            '    4 ├───────────┼───────────────────────━┤',
            '    5 │ `Item 行` │ [link](https://行.com) │',
            '    6 │ &lt;1&gt; │ ==Itém 2==             │',
            '      └───────────┴────────────────────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)
end)
