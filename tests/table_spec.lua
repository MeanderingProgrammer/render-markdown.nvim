---@module 'luassert'

local util = require('tests.util')

describe('table', function()
    ---@param columns integer
    ---@param callback function
    local function with_columns(columns, callback)
        local previous = vim.o.columns
        vim.o.columns = columns
        local ok, err = pcall(callback)
        vim.o.columns = previous
        if not ok then
            error(err, 0)
        end
    end

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

    it('wrapped eof bottom border', function()
        util.setup.text({
            '',
            '| ID | Title | Status |',
            '| -- | ----- | ------ |',
            '| 1 | This sentence is long enough to wrap across several rendered table lines without needing a trailing blank line. | Open |',
        }, {
            pipe_table = { max_table_width = 60 },
            win_options = { wrap = { default = false, rendered = true } },
        })

        util.assert_screen({
            '┌──────┬────────────────────────────────────────┬──────────┐',
            '│ ID   │ Title                                  │ Status   │',
            '├──────┼────────────────────────────────────────┼──────────┤',
            '│ 1    │ This sentence is long enough to wrap   │ Open     │',
            '│      │ across several rendered table lines    │          │',
            '│      │ without needing a trailing blank line. │          │',
            '└──────┴────────────────────────────────────────┴──────────┘',
        })
    end)

    it('wrapped indented table', function()
        with_columns(60, function()
            util.setup.text({
                '',
                '   | Approach | Allocations | Performance |',
                '   |----------|-------------|-------------|',
                '   | `format!()` in loop | N | Slow |',
                '   | `write!()` to reused buffer | 1 | Fast |',
                '   | `push_str()` + `push()` | 1 | Fastest |',
                '   | Pre-sized `String::with_capacity()` | 1 (no realloc) | Fast |',
            }, {
                pipe_table = { max_table_width = -2 },
                win_options = { wrap = { default = false, rendered = true } },
            })

            util.assert_screen({
                '   ┌────────────────────┬────────────────┬───────────────┐',
                '   │ Approach           │ Allocations    │ Performance   │',
                '   ├────────────────────┼────────────────┼───────────────┤',
                '   │ format!() in loop  │ N              │ Slow          │',
                '   │ write!() to        │ 1              │ Fast          │',
                '   │ reused buffer      │                │               │',
                '   │ push_str() +       │ 1              │ Fastest       │',
                '   │ push()             │                │               │',
                '   │ Pre-sized          │ 1 (no realloc) │ Fast          │',
                '   │ String::with_capac │                │               │',
                '   │ ity()              │                │               │',
                '   └────────────────────┴────────────────┴───────────────┘',
            })
        end)
    end)

    it('wrapped showbreak continuation', function()
        with_columns(36, function()
            util.setup.text({
                '',
                '| ID | Title |',
                '| -- | ----- |',
                '| 1 | alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi omicron pi rho sigma tau |',
            }, {
                pipe_table = { max_table_width = 30 },
                win_options = {
                    wrap = { default = false, rendered = true },
                    linebreak = { default = false, rendered = true },
                    showbreak = { default = '', rendered = '>>>>' },
                },
            })

            util.assert_screen({
                '┌──────┬─────────────────────┐',
                '│ ID   │ Title               │',
                '├──────┼─────────────────────┤',
                '│ 1    │ alpha beta gamma    │',
                '│      │ delta epsilon zeta  │',
                '│      │ eta theta iota      │',
                '│      │ kappa lambda mu nu  │',
                '│      │ xi omicron pi rho   │',
                '│      │ sigma tau           │',
                '└──────┴─────────────────────┘',
            })
        end)
    end)

    it('wrapped long delimiter', function()
        util.setup.text({
            '',
            '| ID    | Title                                                                                                                                                                                                                                                                                                                                                                           | Severity | Status |',
            '|-------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|--------|',
            "| [T-1] | Here's a long text that definitely causes wrapping. My hands are typing words. If you're reading this then my hands continued typing words to make long enough a line for testing. Also you possess the highly coveted skill of reading. Good for you. Sorry, didn't mean to sound so sarcastic there. Honestly I'm thrilled for you. I have just trouble showing it. | High     | Open   |",
        }, {
            pipe_table = { max_table_width = 60 },
            win_options = { wrap = { default = false, rendered = true } },
        })

        util.assert_screen({
            '┌─────────┬────────────────────────┬────────────┬──────────┐',
            '│ ID      │ Title                  │ Severity   │ Status   │',
            '├─────────┼────────────────────────┼────────────┼──────────┤',
            "│ T-1     │ Here's a long text     │ High       │ Open     │",
            '│         │ that definitely        │            │          │',
            '│         │ causes wrapping. My    │            │          │',
            '│         │ hands are typing       │            │          │',
            "│         │ words. If you're       │            │          │",
            '│         │ reading this then my   │            │          │',
            '│         │ hands continued        │            │          │',
            '│         │ typing words to make   │            │          │',
            '│         │ long enough a line     │            │          │',
            '│         │ for testing. Also you  │            │          │',
            '│         │ possess the highly     │            │          │',
            '│         │ coveted skill of       │            │          │',
            '│         │ reading. Good for      │            │          │',
            "│         │ you. Sorry, didn't     │            │          │",
            '│         │ mean to sound so       │            │          │',
            '│         │ sarcastic there.       │            │          │',
            "│         │ Honestly I'm thrilled  │            │          │",
            '│         │ for you. I have just   │            │          │',
            '│         │ trouble showing it.    │            │          │',
            '└─────────┴────────────────────────┴────────────┴──────────┘',
        })
    end)
end)
