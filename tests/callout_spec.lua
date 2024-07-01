local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('callout.md', function()
    async_tests.it('default', function()
        util.setup('demo/callout.md')

        local expected = {}
        local quote = '▋'

        local note_start = 0
        vim.list_extend(expected, {
            -- Heading
            {
                row = { note_start, note_start + 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { note_start + 2, note_start + 2 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { note_start + 2, note_start + 2 },
                col = { 2, 9 },
                virt_text = { { '󰋽 Note', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { note_start + 3, note_start + 3 },
                col = { 0, 1 },
                virt_text = { { quote, 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { note_start + 4, note_start + 4 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { note_start + 5, note_start + 5 },
                col = { 0, 1 },
                virt_text = { { quote, 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { note_start + 6, note_start + 6 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
        })

        local tip_start = 8
        vim.list_extend(expected, {
            -- Heading
            {
                row = { tip_start, tip_start + 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { tip_start + 2, tip_start + 2 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { tip_start + 2, tip_start + 2 },
                col = { 2, 8 },
                virt_text = { { '󰌶 Tip', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { tip_start + 3, tip_start + 3 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
        })

        local important_start = 13
        vim.list_extend(expected, {
            -- Heading
            {
                row = { important_start, important_start + 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { important_start + 2, important_start + 2 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { important_start + 2, important_start + 2 },
                col = { 2, 14 },
                virt_text = { { '󰅾 Important', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { important_start + 3, important_start + 3 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
        })

        local warning_start = 18
        vim.list_extend(expected, {
            -- Heading
            {
                row = { warning_start, warning_start + 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { warning_start + 2, warning_start + 2 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { warning_start + 2, warning_start + 2 },
                col = { 2, 12 },
                virt_text = { { '󰀪 Warning', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { warning_start + 3, warning_start + 3 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
        })

        local caution_start = 23
        vim.list_extend(expected, {
            -- Heading
            {
                row = { caution_start, caution_start + 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { caution_start + 2, caution_start + 2 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { caution_start + 2, caution_start + 2 },
                col = { 2, 12 },
                virt_text = { { '󰳦 Caution', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { caution_start + 3, caution_start + 3 },
                col = { 0, 2 },
                virt_text = { { quote .. ' ', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
