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
                row = { 0, 0 },
                col = { 0, 1 },
                sign_text = '󰫎 ',
                sign_hl_group = 'markdownH1',
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
                row = { 2, 2 },
                col = { 0, 3 },
                sign_text = '󰫎 ',
                sign_hl_group = 'markdownH3',
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
                row = { 4, 4 },
                col = { 0, 4 },
                sign_text = '󰫎 ',
                sign_hl_group = 'markdownH4',
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
                row = { 6, 6 },
                col = { 0, 5 },
                sign_text = '󰫎 ',
                sign_hl_group = 'markdownH5',
            },
            {
                row = { 8, 9 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffDelete',
                virt_text = { { '     󰲫 ', { 'markdownH6', 'DiffDelete' } } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 8, 8 },
                col = { 0, 6 },
                sign_text = '󰫎 ',
                sign_hl_group = 'markdownH6',
            },
        })

        -- Image link
        vim.list_extend(expected, {
            {
                row = { 10, 10 },
                col = { 0, 21 },
                virt_text = { { '󰥶 ', '@markup.link.label.markdown_inline' } },
                virt_text_pos = 'inline',
            },
        })

        -- Code block
        vim.list_extend(expected, {
            {
                row = { 12, 23 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'ColorColumn',
            },
            {
                row = { 12, 12 },
                col = { 3, 9 },
                sign_text = '󰌠 ',
                sign_hl_group = 'MiniIconsYellow',
            },
            {
                row = { 12 },
                col = { 3 },
                virt_text = { { '󰌠 python', { 'MiniIconsYellow', 'ColorColumn' } } },
                virt_text_pos = 'inline',
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
