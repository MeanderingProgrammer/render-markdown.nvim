local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('table.md', function()
    async_tests.it('default', function()
        util.setup('tests/data/table.md')

        local expected = {}

        -- Table with inline heading
        vim.list_extend(expected, {
            {
                row = { 0, 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        local table_with_inline = {
            '│ Heading 1 │ `Heading 2` │',
            '├───────────┼───────────┤',
            '│ `Item 1`    │ [link](https://www.example.com)      │',
        }
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 2, 2 },
                col = { 0, 27 },
                virt_text = { { table_with_inline[1], '@markup.heading' } },
                virt_text_pos = 'overlay',
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
                col = { 0, 25 },
                virt_text = { { table_with_inline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row
            {
                row = { 4, 4 },
                col = { 0, 54 },
                virt_text = { { table_with_inline[3], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row inline code
            {
                row = { 4, 4 },
                col = { 2, 10 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
        })

        -- Table no inline heading
        vim.list_extend(expected, {
            {
                row = { 6, 7 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        local table_no_inline = {
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        }
        vim.list_extend(expected, {
            -- Above
            {
                row = { 8 },
                col = { 0 },
                virt_lines = { { { table_no_inline[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading
            {
                row = { 8, 8 },
                col = { 0, 25 },
                virt_text = { { table_no_inline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
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
                row = { 11 },
                col = { 0 },
                virt_lines = { { { table_no_inline[5], 'Normal' } } },
                virt_lines_above = true,
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    async_tests.it('raw', function()
        util.setup('tests/data/table.md', { cell_style = 'raw' })

        local expected = {}

        local table_outline = {
            '┌───────────┬───────────┐',
            '├───────────┼───────────┤',
            '└───────────┴───────────┘',
        }

        -- Table with inline heading
        vim.list_extend(expected, {
            {
                row = { 0, 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        -- Table with inline
        vim.list_extend(expected, {
            -- Above
            {
                row = { 2 },
                col = { 0 },
                virt_lines = { { { table_outline[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading pipe 1
            {
                row = { 2, 2 },
                col = { 0, 0 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Heading pipe 2
            {
                row = { 2, 2 },
                col = { 12, 12 },
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
                col = { 26, 26 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Delimiter
            {
                row = { 3, 3 },
                col = { 0, 25 },
                virt_text = { { table_outline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 1
            {
                row = { 4, 4 },
                col = { 0, 0 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row inline code
            {
                row = { 4, 4 },
                col = { 2, 10 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },

            -- Row pipe 2
            {
                row = { 4, 4 },
                col = { 14, 14 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 3
            {
                row = { 4, 4 },
                col = { 53, 53 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 5 },
                col = { 0 },
                virt_lines = { { { table_outline[3], 'Normal' } } },
                virt_lines_above = true,
            },
        })

        -- Table no inline heading
        vim.list_extend(expected, {
            {
                row = { 6, 7 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        -- Table no inline
        vim.list_extend(expected, {
            -- Above
            {
                row = { 8 },
                col = { 0 },
                virt_lines = { { { table_outline[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading pipe 1
            {
                row = { 8, 8 },
                col = { 0, 0 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Heading pipe 2
            {
                row = { 8, 8 },
                col = { 12, 12 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Heading pipe 3
            {
                row = { 8, 8 },
                col = { 24, 24 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Delimiter
            {
                row = { 9, 9 },
                col = { 0, 25 },
                virt_text = { { table_outline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 1
            {
                row = { 10, 10 },
                col = { 0, 0 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 2
            {
                row = { 10, 10 },
                col = { 12, 12 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row pipe 3
            {
                row = { 10, 10 },
                col = { 24, 24 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 11 },
                col = { 0 },
                virt_lines = { { { table_outline[3], 'Normal' } } },
                virt_lines_above = true,
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
