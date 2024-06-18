local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('callout.md', function()
    async_tests.it('default', function()
        util.setup('demo/callout.md')

        local expected = {}

        -- Note
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 0, 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 2, 2 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 2, 2 },
                col = { 2, 9 },
                virt_text = { { '󰋽 Note', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 3, 3 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Tip
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 5, 6 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 7, 7 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 7, 7 },
                col = { 2, 8 },
                virt_text = { { '󰌶 Tip', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 8, 8 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Important
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 10, 11 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 12, 12 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 12, 12 },
                col = { 2, 14 },
                virt_text = { { '󰅾 Important', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 13, 13 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Warning
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 15, 16 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 17, 17 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 17, 17 },
                col = { 2, 12 },
                virt_text = { { '󰀪 Warning', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 18, 18 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Caution
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 20, 21 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 22, 22 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 22, 22 },
                col = { 2, 12 },
                virt_text = { { '󰳦 Caution', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 23, 23 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
