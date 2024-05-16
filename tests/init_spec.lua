local async_tests = require('plenary.async.tests')
local ui = require('render-markdown.ui')
local util = require('plenary.async.util')

local eq = assert.are.same

async_tests.describe('init', function()
    async_tests.before_each(function()
        require('render-markdown').setup({})
    end)

    async_tests.it('render demo', function()
        vim.cmd('e demo/sample.md')
        util.scheduler()

        local actual = {}
        local marks = vim.api.nvim_buf_get_extmarks(0, ui.namespace, 0, -1, { details = true })
        for _, mark in ipairs(marks) do
            local _, row, col, details = unpack(mark)
            local mark_info = {
                row = { row, details.end_row },
                col = { col, details.end_col },
                hl_eol = details.hl_eol,
                hl_group = details.hl_group,
                virt_text = details.virt_text,
                virt_text_pos = details.virt_text_pos,
                virt_lines = details.virt_lines,
                virt_lines_above = details.virt_lines_above,
            }
            table.insert(actual, mark_info)
        end

        local expected = {}

        -- Headings 1 through 6 (minus 2)
        vim.list_extend(expected, {
            {
                row = { 0, 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 2, 3 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffDelete',
                virt_text = { { '  󰲥 ', { 'markdownH3', 'DiffDelete' } } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 4, 5 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffDelete',
                virt_text = { { '   󰲧 ', { 'markdownH4', 'DiffDelete' } } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 6, 7 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffDelete',
                virt_text = { { '    󰲩 ', { 'markdownH5', 'DiffDelete' } } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 8, 9 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffDelete',
                virt_text = { { '     󰲫 ', { 'markdownH6', 'DiffDelete' } } },
                virt_text_pos = 'overlay',
            },
        })

        -- Code block
        vim.list_extend(expected, {
            {
                row = { 10, 21 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'ColorColumn',
            },
        })

        -- Unordered list
        vim.list_extend(expected, {
            -- List Item 1, bullet point
            {
                row = { 22, 22 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 2, bullet point
            {
                row = { 23, 23 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 2, inline code
            {
                row = { 23, 23 },
                col = { 20, 28 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Nested List 1 Item 1, bullet point
            {
                row = { 24, 24 },
                col = { 2, 6 },
                virt_text = { { '  ○', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 1 Item 2, bullet point
            {
                row = { 25, 25 },
                col = { 4, 6 },
                virt_text = { { '○', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 2 Item 1, bullet point
            {
                row = { 26, 26 },
                col = { 6, 8 },
                virt_text = { { '◆', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 3 Item 1, bullet point
            {
                row = { 27, 27 },
                col = { 8, 10 },
                virt_text = { { '◇', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 4 Item 1, bullet point
            {
                row = { 28, 28 },
                col = { 10, 12 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 3, bullet point
            {
                row = { 29, 29 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Checkboxes
        vim.list_extend(expected, {
            -- Unchecked, bullet point, not created intentionally, remove if fixed
            {
                row = { 35, 35 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Unchecked, checkbox
            {
                row = { 35, 35 },
                col = { 2, 5 },
                virt_text = { { ' 󰄱 ', '@markup.list.unchecked' } },
                virt_text_pos = 'overlay',
            },
            -- Checked, bullet point, not created intentionally, remove if fixed
            {
                row = { 36, 36 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Checked, checkbox
            {
                row = { 36, 36 },
                col = { 2, 5 },
                virt_text = { { '  ', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Line break, TODO: fragile need to determine width
        vim.list_extend(expected, {
            {
                row = { 38 },
                col = { 0 },
                virt_text = { { string.rep('—', 80), 'LineNr' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Quote lines
        vim.list_extend(expected, {
            {
                row = { 40, 40 },
                col = { 0, 4 },
                virt_text = { { '  ┃ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 41, 41 },
                col = { 0, 4 },
                virt_text = { { '  ┃ ', '@markup.quote' } },
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
                row = { 43 },
                col = { 0 },
                virt_lines = { { { markdown_table[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading
            {
                row = { 43, 43 },
                col = { 0, 31 },
                virt_text = { { markdown_table[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Below heading
            {
                row = { 44, 44 },
                col = { 0, 31 },
                virt_text = { { markdown_table[3], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Rows
            {
                row = { 45, 45 },
                col = { 0, 31 },
                virt_text = { { markdown_table[4], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 46, 46 },
                col = { 0, 31 },
                virt_text = { { markdown_table[5], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 47, 47 },
                col = { 0, 31 },
                virt_text = { { markdown_table[6], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 48 },
                col = { 0 },
                virt_lines = { { { markdown_table[7], 'Normal' } } },
                virt_lines_above = true,
            },
        })

        -- LaTeX, TODO: mock interaction with latex2text
        vim.list_extend(expected, {
            -- Inline
            {
                row = { 49, 49 },
                col = { 0, 21 },
                virt_lines = { { { '√(3x-1)+(1+x)^2', '@markup.math' } } },
                virt_lines_above = true,
            },
            -- Block
            {
                row = { 51, 54 },
                col = { 0, 2 },
                virt_lines = {
                    { { 'f(x,y) = x + √(y)', '@markup.math' } },
                    { { 'f(x,y) = √(y) + x^2/4y', '@markup.math' } },
                },
                virt_lines_above = true,
            },
        })

        eq(#expected, #actual)
        for i, expected_mark_info in ipairs(expected) do
            eq(expected_mark_info, actual[i], string.format('Marks at index %d mismatch', i))
        end
    end)
end)
