local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('heading_code.md', function()
    async_tests.it('default', function()
        util.setup('demo/heading_code.md')

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
            {
                row = { 10 },
                col = { 0 },
                virt_text = {
                    { ' ', { 'DevIconPy', 'ColorColumn' } },
                    { 'python ', { 'Normal', 'ColorColumn' } },
                },
                virt_text_pos = 'overlay',
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
