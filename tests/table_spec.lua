---@module 'luassert'

local util = require('tests.util')

describe('table', function()
    local lines = {
        '',
        '| Heading 1 | `Heading 2`            |',
        '| --------- | ---------------------: |',
        '| `Item 行` | [link](https://行.com) |',
        '| &lt;1&gt; | ==Itém 2==             |',
        '',
        '| Heading 1 | Heading 2 |',
        '| --------- | --------- |',
        '| Item 1    | Item 2    |',
    }

    it('default', function()
        util.setup.text(lines)

        local marks, row = util.marks(), util.row()

        marks:add(row:inc(), nil, 0, nil, util.table.border(true, { 11, 24 }))
        marks
            :add(row:get(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(true))
            :add(row:get(), nil, 14, nil, util.table.padding(13))
            :add(row:get(), row:get(), 14, 25, util.highlight('code'))
            :add(row:get(), row:get(), 26, 37, util.conceal())
            :add(row:get(), row:get(), 37, 38, util.table.pipe(true))
        marks:add(row:inc(), row:get(), 0, 38, util.table.delimiter({ { 11 }, { 23, 1 } }))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), row:get(), 2, 12, util.highlight('code'))
            :add(row:get(), nil, 13, nil, util.table.padding(2))
            :add(row:get(), row:get(), 13, 14, util.table.pipe(false))
            :add(row:get(), nil, 15, nil, util.link('web'))
            :add(row:get(), nil, 15, nil, util.table.padding(16))
            :add(row:get(), row:get(), 39, 40, util.table.pipe(false))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), nil, 12, nil, util.table.padding(8))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(false))
            :add(row:get(), nil, 14, nil, util.table.padding(16))
            :add(row:get(), row:get(), 14, 16, util.conceal())
            :add(row:get(), row:get(), 14, 25, util.highlight('inline'))
            :add(row:get(), row:get(), 23, 25, util.conceal())
            :add(row:get(), row:get(), 26, 38, util.conceal())
            :add(row:get(), row:get(), 38, 39, util.table.pipe(false))
        marks:add(row:get(), nil, 0, nil, util.table.border(false, { 11, 24 }))

        marks:add(row:inc(2), nil, 0, nil, util.table.border(true, { 11, 11 }))
        marks
            :add(row:get(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(true))
            :add(row:get(), row:get(), 24, 25, util.table.pipe(true))
        marks:add(row:inc(), row:get(), 0, 25, util.table.delimiter({ { 11 }, { 11 } }))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(false))
            :add(row:get(), row:get(), 24, 25, util.table.pipe(false))
        marks:add(row:get(), nil, 0, nil, util.table.border(false, { 11, 11 }))

        util.assert_view(marks, {
            '',
            '┌───────────┬────────────────────────┐',
            '│ Heading 1 │              Heading 2 │',
            '├───────────┼───────────────────────━┤',
            '│ Item 行   │                 󰖟 link │',
            '│ 1         │                 Itém 2 │',
            '└───────────┴────────────────────────┘',
            '',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        })
    end)

    it('trimmed', function()
        util.setup.text(lines, {
            pipe_table = { cell = 'trimmed' },
        })

        local marks, row = util.marks(), util.row()

        marks:add(row:inc(), nil, 0, nil, util.table.border(true, { 11, 11 }))
        marks
            :add(row:get(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(true))
            :add(row:get(), row:get(), 14, 25, util.highlight('code'))
            :add(row:get(), row:get(), 26, 37, util.conceal())
            :add(row:get(), row:get(), 37, 38, util.table.pipe(true))
        marks:add(row:inc(), row:get(), 0, 38, util.table.delimiter({ { 11 }, { 10, 1 } }, 13))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), row:get(), 2, 12, util.highlight('code'))
            :add(row:get(), nil, 13, nil, util.table.padding(2))
            :add(row:get(), row:get(), 13, 14, util.table.pipe(false))
            :add(row:get(), nil, 15, nil, util.table.padding(3))
            :add(row:get(), nil, 15, nil, util.link('web'))
            :add(row:get(), row:get(), 39, 40, util.table.pipe(false))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), nil, 12, nil, util.table.padding(8))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(false))
            :add(row:get(), nil, 14, nil, util.table.padding(3))
            :add(row:get(), row:get(), 14, 16, util.conceal())
            :add(row:get(), row:get(), 14, 25, util.highlight('inline'))
            :add(row:get(), row:get(), 23, 25, util.conceal())
            :add(row:get(), row:get(), 26, 38, util.conceal())
            :add(row:get(), row:get(), 38, 39, util.table.pipe(false))
        marks:add(row:get(), nil, 0, nil, util.table.border(false, { 11, 11 }))

        marks:add(row:inc(2), nil, 0, nil, util.table.border(true, { 11, 11 }))
        marks
            :add(row:get(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(true))
            :add(row:get(), row:get(), 24, 25, util.table.pipe(true))
        marks:add(row:inc(), row:get(), 0, 25, util.table.delimiter({ { 11 }, { 11 } }))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(false))
            :add(row:get(), row:get(), 24, 25, util.table.pipe(false))
        marks:add(row:get(), nil, 0, nil, util.table.border(false, { 11, 11 }))

        util.assert_view(marks, {
            '',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼──────────━┤',
            '│ Item 行   │    󰖟 link │',
            '│ 1         │    Itém 2 │',
            '└───────────┴───────────┘',
            '',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        })
    end)

    it('raw', function()
        util.setup.text(lines, {
            pipe_table = { cell = 'raw' },
        })

        local marks, row = util.marks(), util.row()

        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(true))
            :add(row:get(), row:get(), 14, 25, util.highlight('code'))
            :add(row:get(), row:get(), 37, 38, util.table.pipe(true))
        marks:add(row:inc(), row:get(), 0, 38, util.table.delimiter({ { 11 }, { 23, 1 } }))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), row:get(), 2, 12, util.highlight('code'))
            :add(row:get(), row:get(), 13, 14, util.table.pipe(false))
            :add(row:get(), nil, 15, nil, util.link('web'))
            :add(row:get(), row:get(), 39, 40, util.table.pipe(false))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(false))
            :add(row:get(), row:get(), 14, 16, util.conceal())
            :add(row:get(), row:get(), 14, 25, util.highlight('inline'))
            :add(row:get(), row:get(), 23, 25, util.conceal())
            :add(row:get(), row:get(), 38, 39, util.table.pipe(false))

        marks:add(row:inc(2), nil, 0, nil, util.table.border(true, { 11, 11 }))
        marks
            :add(row:get(), row:get(), 0, 1, util.table.pipe(true))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(true))
            :add(row:get(), row:get(), 24, 25, util.table.pipe(true))
        marks:add(row:inc(), row:get(), 0, 25, util.table.delimiter({ { 11 }, { 11 } }))
        marks
            :add(row:inc(), row:get(), 0, 1, util.table.pipe(false))
            :add(row:get(), row:get(), 12, 13, util.table.pipe(false))
            :add(row:get(), row:get(), 24, 25, util.table.pipe(false))
        marks:add(row:get(), nil, 0, nil, util.table.border(false, { 11, 11 }))

        util.assert_view(marks, {
            '',
            '│ Heading 1 │ Heading 2            │',
            '├───────────┼───────────────────────━┤',
            '│ Item 行 │ 󰖟 link │',
            '│ 1 │ Itém 2             │',
            '',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        })
    end)

    it('overlay', function()
        util.setup.text(lines, {
            pipe_table = { cell = 'overlay' },
        })

        local marks, row = util.marks(), util.row()

        marks:add(row:inc(), nil, 0, nil, util.table.border(true, { 11, 24 }))
        marks:add(row:get(), row:get(), 0, 38, {
            virt_text = { { '│ Heading 1 │ `Heading 2`            │', 'RmTableHead' } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(), row:get(), 14, 25, util.highlight('code'))
        marks:add(row:inc(), row:get(), 0, 38, util.table.delimiter({ { 11 }, { 23, 1 } }))
        marks:add(row:inc(), row:get(), 0, 40, {
            virt_text = { { '│ `Item 行` │ [link](https://行.com) │', 'RmTableRow' } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(), row:get(), 2, 12, util.highlight('code'))
        marks:add(row:get(), nil, 15, nil, util.link('web'))
        marks:add(row:inc(), row:get(), 0, 39, {
            virt_text = { { '│ &lt;1&gt; │ ==Itém 2==             │', 'RmTableRow' } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(), row:get(), 14, 16, util.conceal())
        marks:add(row:get(), row:get(), 14, 25, util.highlight('inline'))
        marks:add(row:get(), row:get(), 23, 25, util.conceal())
        marks:add(row:get(), nil, 0, nil, util.table.border(false, { 11, 24 }))

        marks:add(row:inc(2), nil, 0, nil, util.table.border(true, { 11, 11 }))
        marks:add(row:get(), row:get(), 0, 25, {
            virt_text = { { '│ Heading 1 │ Heading 2 │', 'RmTableHead' } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:inc(), row:get(), 0, 25, util.table.delimiter({ { 11 }, { 11 } }))
        marks:add(row:inc(), row:get(), 0, 25, {
            virt_text = { { '│ Item 1    │ Item 2    │', 'RmTableRow' } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(), nil, 0, nil, util.table.border(false, { 11, 11 }))

        util.assert_view(marks, {
            '',
            '┌───────────┬────────────────────────┐',
            '│ Heading 1 │ `Heading 2`            │',
            '├───────────┼───────────────────────━┤',
            '│ `Item 行` │ [link](https://行.com) │',
            '│ &lt;1&gt; │ ==Itém 2==             │',
            '└───────────┴────────────────────────┘',
            '',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        })
    end)
end)
