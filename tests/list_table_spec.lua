local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('list_table.md', function()
    async_tests.it('default', function()
        util.setup('demo/list_table.md')

        local expected = {}

        -- Unordered list heading
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

        -- Unordered list
        vim.list_extend(expected, {
            -- List Item 1, bullet point
            {
                row = { 2, 2 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
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
        vim.list_extend(expected, {
            {
                row = { 11, 12 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        -- Table heading
        vim.list_extend(expected, {
            {
                row = { 17, 18 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        local markdown_table = {
            '┌──────────────┬──────────────┐',
            '│ Heading 1    │ Heading 2    │',
            '├──────────────┼──────────────┤',
            '│ Row 1 Item 1 │ Row 1 Item 2 │',
            '│ Row 2 Item 1 │ Row 2 Item 2 │',
            '│ Row 3 Item 1 │ Row 3 Item 2 │',
            '└──────────────┴──────────────┘',
        }
        vim.list_extend(expected, {
            -- Above
            {
                row = { 19 },
                col = { 0 },
                virt_lines = { { { markdown_table[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading
            {
                row = { 19, 19 },
                col = { 0, 31 },
                virt_text = { { markdown_table[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Delimiter
            {
                row = { 20, 20 },
                col = { 0, 31 },
                virt_text = { { markdown_table[3], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Row 1
            {
                row = { 21, 21 },
                col = { 0, 31 },
                virt_text = { { markdown_table[4], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row 2
            {
                row = { 22, 22 },
                col = { 0, 31 },
                virt_text = { { markdown_table[5], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Row 3
            {
                row = { 23, 23 },
                col = { 0, 31 },
                virt_text = { { markdown_table[6], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 24 },
                col = { 0 },
                virt_lines = { { { markdown_table[7], 'Normal' } } },
                virt_lines_above = true,
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
