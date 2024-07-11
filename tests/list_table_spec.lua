local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('list_table.md', function()
    async_tests.it('default', function()
        util.setup('demo/list_table.md')

        local expected = {}

        -- Unordered list heading
        vim.list_extend(expected, util.heading(0, 1))

        -- Unordered list
        vim.list_extend(expected, {
            -- List Item 1, bullet point
            {
                row = { 2, 2 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 1, link
            {
                row = { 2, 2 },
                col = { 20, 47 },
                virt_text = { { '󰌹 ', '@markup.link.label.markdown_inline' } },
                virt_text_pos = 'inline',
            },
            -- List Item 2, bullet point
            {
                row = { 3, 3 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 2, inline code
            {
                row = { 3, 3 },
                col = { 20, 28 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Nested List 1 Item 1, bullet point
            {
                row = { 4, 4 },
                col = { 2, 6 },
                virt_text = { { '  ○', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 1 Item 2, bullet point
            {
                row = { 5, 5 },
                col = { 4, 6 },
                virt_text = { { '○', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 2 Item 1, bullet point
            {
                row = { 6, 6 },
                col = { 6, 8 },
                virt_text = { { '◆', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 3 Item 1, bullet point
            {
                row = { 7, 7 },
                col = { 8, 10 },
                virt_text = { { '◇', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 4 Item 1, bullet point
            {
                row = { 8, 8 },
                col = { 10, 12 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 3, bullet point
            {
                row = { 9, 9 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Ordered list heading
        vim.list_extend(expected, util.heading(11, 1))

        -- Table heading
        vim.list_extend(expected, util.heading(17, 1))

        local table_outline = {
            '┌──────────────────┬────────────────────┐',
            '├──────────────────┼────────────────────┤',
            '└──────────────────┴────────────────────┘',
        }
        vim.list_extend(expected, {
            -- Above
            {
                row = { 19 },
                col = { 0 },
                virt_lines = { { { table_outline[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading pipe 1
            {
                row = { 19, 19 },
                col = { 0, 1 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Inline code in heading
            {
                row = { 19, 19 },
                col = { 2, 18 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Heading padding 1
            {
                row = { 19 },
                col = { 19 },
                virt_text = { { '  ', 'Conceal' } },
                virt_text_pos = 'inline',
            },
            -- Heading pipe 2
            {
                row = { 19, 19 },
                col = { 19, 20 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Heading padding 2
            {
                row = { 19 },
                col = { 40 },
                virt_text = { { '  ', 'Conceal' } },
                virt_text_pos = 'inline',
            },
            -- Heading pipe 2
            {
                row = { 19, 19 },
                col = { 40, 41 },
                virt_text = { { '│', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Delimiter
            {
                row = { 20, 20 },
                col = { 0, 41 },
                virt_text = { { table_outline[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row 1 pipe 1
            {
                row = { 21, 21 },
                col = { 0, 1 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row 1 pipe 2
            {
                row = { 21, 21 },
                col = { 19, 20 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row 1 padding 2
            {
                row = { 21 },
                col = { 40 },
                virt_text = { { '    ', 'Conceal' } },
                virt_text_pos = 'inline',
            },
            -- Row 1 pipe 3
            {
                row = { 21, 21 },
                col = { 40, 41 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row 2 pipe 1
            {
                row = { 22, 22 },
                col = { 0, 1 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row 2 inline code
            {
                row = { 22, 22 },
                col = { 2, 15 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Row 2 padding 1
            {
                row = { 22 },
                col = { 19 },
                virt_text = { { '  ', 'Conceal' } },
                virt_text_pos = 'inline',
            },
            -- Row 2 pipe 2
            {
                row = { 22, 22 },
                col = { 19, 20 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row 2 link
            {
                row = { 22, 22 },
                col = { 21, 39 },
                virt_text = { { '󰌹 ', '@markup.link.label.markdown_inline' } },
                virt_text_pos = 'inline',
            },
            -- Row 2 padding 2
            {
                row = { 22 },
                col = { 40 },
                virt_text = { { '       ', 'Conceal' } },
                virt_text_pos = 'inline',
            },
            -- Row 2 pipe 3
            {
                row = { 22, 22 },
                col = { 40, 41 },
                virt_text = { { '│', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 23 },
                col = { 0 },
                virt_lines = { { { table_outline[3], 'Normal' } } },
                virt_lines_above = true,
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
