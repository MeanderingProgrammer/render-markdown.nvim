---@module 'luassert'

local util = require('tests.util')

local lines = {
    '',
    '| Heading 1 | `Heading 2`            |',
    '| --------- | ---------------------: |',
    '| `Item 行` | [link](https://行.com) |',
    '| &lt;1&gt; | ==Itém 2==             |',
    '| Regular   | [[行\\|link]]           |',
    '',
    '| Heading 1 | Heading 2 |',
    '| --------- | --------- |',
    '| Item 1    | Item 2    |',
}

---@return render.md.test.Marks
local function shared()
    local marks, row = util.marks(), util.row()

    marks:add(row:get(1, 0), { 14, 25 }, util.highlight('code'))

    marks:add(row:get(2, 0), { 2, 12 }, util.highlight('code'))

    marks:add(row:get(0), 15, util.link('web'))

    marks:add(row:get(1, 0), { 14, 16 }, util.conceal())
    marks:add(row:get(0, 0), { 14, 25 }, util.highlight('inline'))
    marks:add(row:get(0, 0), { 23, 25 }, util.conceal())

    marks:add(row:get(1, 0), { 14, 16 }, util.conceal())
    marks:add(row:get(0), 16, util.link('wiki'))
    marks:add(row:get(0, 0), { 16, 21 }, util.conceal())
    marks:add(row:get(0, 0), { 25, 27 }, util.conceal())

    return marks
end

---@return render.md.test.Marks
local function pipes()
    local marks, row = util.marks(), util.row()

    marks:add(row:get(1, 0), { 0, 1 }, util.table.pipe(true))
    marks:add(row:get(0, 0), { 12, 13 }, util.table.pipe(true))
    marks:add(row:get(0, 0), { 37, 38 }, util.table.pipe(true))
    marks:add(row:get(2, 0), { 0, 1 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 13, 14 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 39, 40 }, util.table.pipe(false))
    marks:add(row:get(1, 0), { 0, 1 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 12, 13 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 38, 39 }, util.table.pipe(false))
    marks:add(row:get(1, 0), { 0, 1 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 12, 13 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 38, 39 }, util.table.pipe(false))

    marks:add(row:get(2, 0), { 0, 1 }, util.table.pipe(true))
    marks:add(row:get(0, 0), { 12, 13 }, util.table.pipe(true))
    marks:add(row:get(0, 0), { 24, 25 }, util.table.pipe(true))
    marks:add(row:get(2, 0), { 0, 1 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 12, 13 }, util.table.pipe(false))
    marks:add(row:get(0, 0), { 24, 25 }, util.table.pipe(false))

    return marks
end

describe('table', function()
    it('default', function()
        util.setup.text(lines)

        local marks, row = shared(), util.row()
        marks:extend(pipes())

        marks:add(row:get(0), 0, util.table.border(false, true, 11, 24))
        marks:add(row:get(1), 14, util.table.padding(13))
        marks:add(row:get(0, 0), { 26, 37 }, util.conceal())
        marks:add(
            row:get(1, 0),
            { 0, 38 },
            util.table.delimiter(0, { 11 }, { 23, 1 })
        )
        marks:add(row:get(1), 13, util.table.padding(2))
        marks:add(row:get(0), 15, util.table.padding(16))
        marks:add(row:get(1), 12, util.table.padding(8))
        marks:add(row:get(0), 14, util.table.padding(16))
        marks:add(row:get(0, 0), { 26, 38 }, util.conceal())
        marks:add(row:get(1), 14, util.table.padding(16))
        marks:add(row:get(0, 0), { 28, 38 }, util.conceal())
        marks:add(row:get(1), 0, util.table.border(false, false, 11, 24))

        marks:add(row:get(1), 0, util.table.border(true, true, 11, 11))
        marks:add(
            row:get(1, 0),
            { 0, 25 },
            util.table.delimiter(0, { 11 }, { 11 })
        )
        marks:add(row:get(1), 0, util.table.border(true, false, 11, 11))

        util.assert_view(marks, {
            '┌───────────┬────────────────────────┐',
            '│ Heading 1 │              Heading 2 │',
            '├───────────┼───────────────────────━┤',
            '│ Item 行   │                 󰖟 link │',
            '│ 1         │                 Itém 2 │',
            '│ Regular   │                 󱗖 link │',
            '└───────────┴────────────────────────┘',
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

        local marks, row = shared(), util.row()
        marks:extend(pipes())

        marks:add(row:get(0), 0, util.table.border(false, true, 11, 11))
        marks:add(row:get(1, 0), { 26, 37 }, util.conceal())
        marks:add(
            row:get(1, 0),
            { 0, 38 },
            util.table.delimiter(13, { 11 }, { 10, 1 })
        )
        marks:add(row:get(1), 13, util.table.padding(2))
        marks:add(row:get(0), 15, util.table.padding(3))
        marks:add(row:get(1), 12, util.table.padding(8))
        marks:add(row:get(0), 14, util.table.padding(3))
        marks:add(row:get(0, 0), { 26, 38 }, util.conceal())
        marks:add(row:get(1), 14, util.table.padding(3))
        marks:add(row:get(0, 0), { 28, 38 }, util.conceal())
        marks:add(row:get(1), 0, util.table.border(false, false, 11, 11))

        marks:add(row:get(1), 0, util.table.border(true, true, 11, 11))
        marks:add(
            row:get(1, 0),
            { 0, 25 },
            util.table.delimiter(0, { 11 }, { 11 })
        )
        marks:add(row:get(1), 0, util.table.border(true, false, 11, 11))

        util.assert_view(marks, {
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼──────────━┤',
            '│ Item 行   │    󰖟 link │',
            '│ 1         │    Itém 2 │',
            '│ Regular   │    󱗖 link │',
            '└───────────┴───────────┘',
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

        local marks, row = shared(), util.row()
        marks:extend(pipes())

        marks:add(
            row:get(2, 0),
            { 0, 38 },
            util.table.delimiter(0, { 11 }, { 23, 1 })
        )

        marks:add(row:get(4), 0, util.table.border(false, true, 11, 11))
        marks:add(
            row:get(2, 0),
            { 0, 25 },
            util.table.delimiter(0, { 11 }, { 11 })
        )
        marks:add(row:get(1), 0, util.table.border(true, false, 11, 11))

        util.assert_view(marks, {
            '',
            '│ Heading 1 │ Heading 2            │',
            '├───────────┼───────────────────────━┤',
            '│ Item 行 │ 󰖟 link │',
            '│ 1 │ Itém 2             │',
            '│ Regular   │ 󱗖 link           │',
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

        local marks, row = shared(), util.row()

        marks:add(row:get(0), 0, util.table.border(false, true, 11, 24))
        marks:add(row:get(1, 0), { 0, 38 }, {
            virt_text = {
                {
                    '│ Heading 1 │ `Heading 2`            │',
                    'RmTableHead',
                },
            },
            virt_text_pos = 'overlay',
        })
        marks:add(
            row:get(1, 0),
            { 0, 38 },
            util.table.delimiter(0, { 11 }, { 23, 1 })
        )
        marks:add(row:get(1, 0), { 0, 40 }, {
            virt_text = {
                {
                    '│ `Item 行` │ [link](https://行.com) │',
                    'RmTableRow',
                },
            },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 39 }, {
            virt_text = {
                {
                    '│ &lt;1&gt; │ ==Itém 2==             │',
                    'RmTableRow',
                },
            },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 39 }, {
            virt_text = {
                {
                    '│ Regular   │ [[行\\│link]]           │',
                    'RmTableRow',
                },
            },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1), 0, util.table.border(false, false, 11, 24))

        marks:add(row:get(1), 0, util.table.border(true, true, 11, 11))
        marks:add(row:get(0, 0), { 0, 25 }, {
            virt_text = { { '│ Heading 1 │ Heading 2 │', 'RmTableHead' } },
            virt_text_pos = 'overlay',
        })
        marks:add(
            row:get(1, 0),
            { 0, 25 },
            util.table.delimiter(0, { 11 }, { 11 })
        )
        marks:add(row:get(1, 0), { 0, 25 }, {
            virt_text = { { '│ Item 1    │ Item 2    │', 'RmTableRow' } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(0), 0, util.table.border(true, false, 11, 11))

        util.assert_view(marks, {
            '┌───────────┬────────────────────────┐',
            '│ Heading 1 │ `Heading 2`            │',
            '├───────────┼───────────────────────━┤',
            '│ `Item 行` │ [link](https://行.com) │',
            '│ &lt;1&gt; │ ==Itém 2==             │',
            '│ Regular   │ [[行\\│link]]           │',
            '└───────────┴────────────────────────┘',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        })
    end)
end)
