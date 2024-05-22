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

        -- Callouts
        vim.list_extend(expected, {
            -- Note, quote
            {
                row = { 22, 22 },
                col = { 0, 2 },
                virt_text = { { '┃ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
            -- Note, text
            {
                row = { 22, 22 },
                col = { 2, 9 },
                virt_text = { { '  Note', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            -- Tip, quote
            {
                row = { 23, 23 },
                col = { 0, 2 },
                virt_text = { { '┃ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
            -- Tip, text
            {
                row = { 23, 23 },
                col = { 2, 8 },
                virt_text = { { '  Tip', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
            -- Important, quote
            {
                row = { 24, 24 },
                col = { 0, 2 },
                virt_text = { { '┃ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
            -- Important, text
            {
                row = { 24, 24 },
                col = { 2, 14 },
                virt_text = { { '󰅾  Important', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
            -- Warning, quote
            {
                row = { 25, 25 },
                col = { 0, 2 },
                virt_text = { { '┃ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
            -- Warning, text
            {
                row = { 25, 25 },
                col = { 2, 12 },
                virt_text = { { '  Warning', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
            -- Caution, quote
            {
                row = { 26, 26 },
                col = { 0, 2 },
                virt_text = { { '┃ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
            -- Caution, text
            {
                row = { 26, 26 },
                col = { 2, 12 },
                virt_text = { { '󰳦  Caution', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Unordered list
        vim.list_extend(expected, {
            -- List Item 1, bullet point
            {
                row = { 28, 28 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 2, bullet point
            {
                row = { 29, 29 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 2, inline code
            {
                row = { 29, 29 },
                col = { 20, 28 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Nested List 1 Item 1, bullet point
            {
                row = { 30, 30 },
                col = { 2, 6 },
                virt_text = { { '  ○', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 1 Item 2, bullet point
            {
                row = { 31, 31 },
                col = { 4, 6 },
                virt_text = { { '○', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 2 Item 1, bullet point
            {
                row = { 32, 32 },
                col = { 6, 8 },
                virt_text = { { '◆', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 3 Item 1, bullet point
            {
                row = { 33, 33 },
                col = { 8, 10 },
                virt_text = { { '◇', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 4 Item 1, bullet point
            {
                row = { 34, 34 },
                col = { 10, 12 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 3, bullet point
            {
                row = { 35, 35 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Checkboxes
        vim.list_extend(expected, {
            -- Unchecked, list marker
            {
                row = { 41, 41 },
                col = { 0, 2 },
                virt_text = { { '  ', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Unchecked, checkbox
            {
                row = { 41, 41 },
                col = { 2, 5 },
                virt_text = { { ' 󰄱 ', '@markup.list.unchecked' } },
                virt_text_pos = 'overlay',
            },
            -- Checked, list marker
            {
                row = { 42, 42 },
                col = { 0, 2 },
                virt_text = { { '  ', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Checked, checkbox
            {
                row = { 42, 42 },
                col = { 2, 5 },
                virt_text = { { '  ', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Line break
        vim.list_extend(expected, {
            {
                row = { 44 },
                col = { 0 },
                virt_text = { { string.rep('—', vim.opt.columns:get()), 'LineNr' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Quote lines
        vim.list_extend(expected, {
            {
                row = { 46, 46 },
                col = { 0, 4 },
                virt_text = { { '  ┃ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 47, 47 },
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
                row = { 49 },
                col = { 0 },
                virt_lines = { { { markdown_table[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading
            {
                row = { 49, 49 },
                col = { 0, 31 },
                virt_text = { { markdown_table[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Below heading
            {
                row = { 50, 50 },
                col = { 0, 31 },
                virt_text = { { markdown_table[3], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Rows
            {
                row = { 51, 51 },
                col = { 0, 31 },
                virt_text = { { markdown_table[4], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 52, 52 },
                col = { 0, 31 },
                virt_text = { { markdown_table[5], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 53, 53 },
                col = { 0, 31 },
                virt_text = { { markdown_table[6], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 54 },
                col = { 0 },
                virt_lines = { { { markdown_table[7], 'Normal' } } },
                virt_lines_above = true,
            },
        })

        -- LaTeX, TODO: mock interaction with latex2text
        vim.list_extend(expected, {
            -- Inline
            {
                row = { 55, 55 },
                col = { 0, 21 },
                virt_lines = { { { '√(3x-1)+(1+x)^2', '@markup.math' } } },
                virt_lines_above = true,
            },
            -- Block
            {
                row = { 57, 60 },
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
