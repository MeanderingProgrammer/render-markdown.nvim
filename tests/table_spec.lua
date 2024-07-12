local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('table.md', function()
    async_tests.it('default', function()
        util.setup('tests/data/table.md')

        local expected = {}

        -- Table with inline heading
        vim.list_extend(expected, util.heading(0, 1))

        local table_with_inline = {
            '┌───────────┬────────────────────────┐',
            '├───────────┼────────────────────────┤',
            '└───────────┴────────────────────────┘',
        }
        vim.list_extend(expected, {
            util.table_pipe(2, 0, true), -- Heading pipe 1
            util.table_border(2, table_with_inline[1], true), -- Above
            util.table_pipe(2, 12, true), -- Heading pipe 2
            util.inline_code(2, 14, 25), -- Inline code in heading
            util.table_padding(2, 37, 2), -- Heading padding 2
            util.table_pipe(2, 37, true), -- Heading pipe 3
            util.table_row(3, 38, table_with_inline[2], true), -- Delimiter
            util.table_pipe(4, 0, false), -- Row pipe 1
            util.table_border(4, table_with_inline[3], false), -- Below
            util.inline_code(4, 2, 12), -- Row inline code
            util.table_padding(4, 13, 2), -- Row padding 1
            util.table_pipe(4, 13, false), -- Row pipe 2
            util.link(4, 15, 38, false), -- Row link
            util.table_padding(4, 39, 16), -- Row padding 2
            util.table_pipe(4, 39, false), -- Row pipe 3
        })

        -- Table no inline heading
        vim.list_extend(expected, util.heading(6, 1))

        local table_no_inline = {
            '┌───────────┬───────────┐',
            '├───────────┼───────────┤',
            '└───────────┴───────────┘',
        }
        vim.list_extend(expected, {
            util.table_pipe(8, 0, true), -- Heading pipe 1
            util.table_border(8, table_no_inline[1], true), -- Above
            util.table_pipe(8, 12, true), -- Heading pipe 2
            util.table_pipe(8, 24, true), -- Heading pipe 3
            util.table_row(9, 25, table_no_inline[2], true), -- Delimiter
            util.table_pipe(10, 0, false), -- Row pipe 1
            util.table_border(10, table_no_inline[3], false), -- Below
            util.table_pipe(10, 12, false), -- Row pipe 2
            util.table_pipe(10, 24, false), -- Row pipe 3
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    async_tests.it('raw', function()
        util.setup('tests/data/table.md', { pipe_table = { cell = 'raw' } })

        local expected = {}

        -- Table with inline heading
        vim.list_extend(expected, util.heading(0, 1))

        local table_with_inline = {
            '├───────────┼────────────────────────┤',
        }
        vim.list_extend(expected, {
            util.table_pipe(2, 0, true), -- Heading pipe 1
            util.table_pipe(2, 12, true), -- Heading pipe 2
            util.inline_code(2, 14, 25), -- Inline code in heading
            util.table_pipe(2, 37, true), -- Heading pipe 3
            util.table_row(3, 38, table_with_inline[1], true), -- Delimiter
            util.table_pipe(4, 0, false), -- Row pipe 1
            util.inline_code(4, 2, 12), -- Row inline code
            util.table_pipe(4, 13, false), -- Row pipe 2
            util.link(4, 15, 38, false), -- Row link
            util.table_pipe(4, 39, false), -- Row pipe 3
        })

        -- Table no inline heading
        vim.list_extend(expected, util.heading(6, 1))

        local table_no_inline = {
            '┌───────────┬───────────┐',
            '├───────────┼───────────┤',
            '└───────────┴───────────┘',
        }
        vim.list_extend(expected, {
            util.table_pipe(8, 0, true), -- Heading pipe 1
            util.table_border(8, table_no_inline[1], true), -- Above
            util.table_pipe(8, 12, true), -- Heading pipe 2
            util.table_pipe(8, 24, true), -- Heading pipe 3
            util.table_row(9, 25, table_no_inline[2], true), -- Delimiter
            util.table_pipe(10, 0, false), -- Row pipe 1
            util.table_border(10, table_no_inline[3], false), -- Below
            util.table_pipe(10, 12, false), -- Row pipe 2
            util.table_pipe(10, 24, false), -- Row pipe 3
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    async_tests.it('overlay', function()
        util.setup('tests/data/table.md', { pipe_table = { cell = 'overlay' } })

        local expected = {}

        -- Table with inline heading
        vim.list_extend(expected, util.heading(0, 1))

        local table_with_inline = {
            '┌───────────┬────────────────────────┐',
            '│ Heading 1 │ `Heading 2`            │',
            '├───────────┼────────────────────────┤',
            '│ `Item 行` │ [link](https://行.com) │',
            '└───────────┴────────────────────────┘',
        }
        vim.list_extend(expected, {
            util.table_row(2, 38, table_with_inline[2], true), -- Heading
            util.table_border(2, table_with_inline[1], true), -- Above
            util.inline_code(2, 14, 25), -- Inline code in heading
            util.table_row(3, 38, table_with_inline[3], true), -- Delimiter
            util.table_row(4, 40, table_with_inline[4], false), -- Row
            util.table_border(4, table_with_inline[5], false), -- Below
            util.inline_code(4, 2, 12), -- Row inline code
            util.link(4, 15, 38, false), -- Row link
        })

        -- Table no inline heading
        vim.list_extend(expected, util.heading(6, 1))

        local table_no_inline = {
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        }
        vim.list_extend(expected, {
            util.table_row(8, 25, table_no_inline[2], true), -- Heading
            util.table_border(8, table_no_inline[1], true), -- Above
            util.table_row(9, 25, table_no_inline[3], true), -- Delimiter
            util.table_row(10, 25, table_no_inline[4], false), -- Row
            util.table_border(10, table_no_inline[5], false), -- Below
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
