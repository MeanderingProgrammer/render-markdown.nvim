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
            -- Heading pipe 1
            {
                row = { 2, 2 },
                col = { 0, 1 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Above
            {
                row = { 2 },
                col = { 0 },
                virt_lines = { { { table_with_inline[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading pipe 2
            {
                row = { 2, 2 },
                col = { 12, 13 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Inline code in heading
            {
                row = { 2, 2 },
                col = { 14, 25 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Heading padding 2
            {
                row = { 2 },
                col = { 37 },
                virt_text = { { '  ', 'Conceal' } },
                virt_text_pos = 'inline',
            },
            -- Heading pipe 3
            {
                row = { 2, 2 },
                col = { 37, 38 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Delimiter
            {
                row = { 3, 3 },
                col = { 0, 38 },
                virt_text = { { table_with_inline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 1
            {
                row = { 4, 4 },
                col = { 0, 1 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 4 },
                col = { 0 },
                virt_lines = { { { table_with_inline[3], 'Normal' } } },
                virt_lines_above = false,
            },
            -- Row inline code
            {
                row = { 4, 4 },
                col = { 2, 12 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Row padding 1
            {
                row = { 4 },
                col = { 13 },
                virt_text = { { '  ', 'Conceal' } },
                virt_text_pos = 'inline',
            },
            -- Row pipe 2
            {
                row = { 4, 4 },
                col = { 13, 14 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row link
            {
                row = { 4, 4 },
                col = { 15, 38 },
                virt_text = { { '󰌹 ', '@markup.link.label.markdown_inline' } },
                virt_text_pos = 'inline',
            },
            -- Row padding 2
            {
                row = { 4 },
                col = { 39 },
                virt_text = { { '                ', 'Conceal' } },
                virt_text_pos = 'inline',
            },
            -- Row pipe 3
            {
                row = { 4, 4 },
                col = { 39, 40 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Table no inline heading
        vim.list_extend(expected, util.heading(6, 1))

        local table_no_inline = {
            '┌───────────┬───────────┐',
            '├───────────┼───────────┤',
            '└───────────┴───────────┘',
        }
        vim.list_extend(expected, {
            -- Heading pipe 1
            {
                row = { 8, 8 },
                col = { 0, 1 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Above
            {
                row = { 8 },
                col = { 0 },
                virt_lines = { { { table_no_inline[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading pipe 2
            {
                row = { 8, 8 },
                col = { 12, 13 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Heading pipe 3
            {
                row = { 8, 8 },
                col = { 24, 25 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Delimiter
            {
                row = { 9, 9 },
                col = { 0, 25 },
                virt_text = { { table_no_inline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 1
            {
                row = { 10, 10 },
                col = { 0, 1 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 10 },
                col = { 0 },
                virt_lines = { { { table_no_inline[3], 'Normal' } } },
                virt_lines_above = false,
            },
            -- Row pipe 2
            {
                row = { 10, 10 },
                col = { 12, 13 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 3
            {
                row = { 10, 10 },
                col = { 24, 25 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
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
            -- Heading pipe 1
            {
                row = { 2, 2 },
                col = { 0, 1 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Heading pipe 2
            {
                row = { 2, 2 },
                col = { 12, 13 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Inline code in heading
            {
                row = { 2, 2 },
                col = { 14, 25 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Heading pipe 3
            {
                row = { 2, 2 },
                col = { 37, 38 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Delimiter
            {
                row = { 3, 3 },
                col = { 0, 38 },
                virt_text = { { table_with_inline[1], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 1
            {
                row = { 4, 4 },
                col = { 0, 1 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row inline code
            {
                row = { 4, 4 },
                col = { 2, 12 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Row pipe 2
            {
                row = { 4, 4 },
                col = { 13, 14 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row link
            {
                row = { 4, 4 },
                col = { 15, 38 },
                virt_text = { { '󰌹 ', '@markup.link.label.markdown_inline' } },
                virt_text_pos = 'inline',
            },
            -- Row pipe 3
            {
                row = { 4, 4 },
                col = { 39, 40 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Table no inline heading
        vim.list_extend(expected, util.heading(6, 1))

        local table_no_inline = {
            '┌───────────┬───────────┐',
            '├───────────┼───────────┤',
            '└───────────┴───────────┘',
        }
        vim.list_extend(expected, {
            -- Heading pipe 1
            {
                row = { 8, 8 },
                col = { 0, 1 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Above
            {
                row = { 8 },
                col = { 0 },
                virt_lines = { { { table_no_inline[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading pipe 2
            {
                row = { 8, 8 },
                col = { 12, 13 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Heading pipe 3
            {
                row = { 8, 8 },
                col = { 24, 25 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Delimiter
            {
                row = { 9, 9 },
                col = { 0, 25 },
                virt_text = { { table_no_inline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 1
            {
                row = { 10, 10 },
                col = { 0, 1 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 10 },
                col = { 0 },
                virt_lines = { { { table_no_inline[3], 'Normal' } } },
                virt_lines_above = false,
            },
            -- Row pipe 2
            {
                row = { 10, 10 },
                col = { 12, 13 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 3
            {
                row = { 10, 10 },
                col = { 24, 25 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
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
            -- Heading
            {
                row = { 2, 2 },
                col = { 0, 38 },
                virt_text = { { table_with_inline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Above
            {
                row = { 2 },
                col = { 0 },
                virt_lines = { { { table_with_inline[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Inline code in heading
            {
                row = { 2, 2 },
                col = { 14, 25 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Delimiter
            {
                row = { 3, 3 },
                col = { 0, 38 },
                virt_text = { { table_with_inline[3], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row
            {
                row = { 4, 4 },
                col = { 0, 40 },
                virt_text = { { table_with_inline[4], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 4 },
                col = { 0 },
                virt_lines = { { { table_with_inline[5], 'Normal' } } },
                virt_lines_above = false,
            },
            -- Row inline code
            {
                row = { 4, 4 },
                col = { 2, 12 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Row link
            {
                row = { 4, 4 },
                col = { 15, 38 },
                virt_text = { { '󰌹 ', '@markup.link.label.markdown_inline' } },
                virt_text_pos = 'inline',
            },
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
            -- Heading
            {
                row = { 8, 8 },
                col = { 0, 25 },
                virt_text = { { table_no_inline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Above
            {
                row = { 8 },
                col = { 0 },
                virt_lines = { { { table_no_inline[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Delimiter
            {
                row = { 9, 9 },
                col = { 0, 25 },
                virt_text = { { table_no_inline[3], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row
            {
                row = { 10, 10 },
                col = { 0, 25 },
                virt_text = { { table_no_inline[4], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 10 },
                col = { 0 },
                virt_lines = { { { table_no_inline[5], 'Normal' } } },
                virt_lines_above = false,
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
