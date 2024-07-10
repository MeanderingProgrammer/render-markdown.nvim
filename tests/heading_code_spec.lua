local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('heading_code.md', function()
    async_tests.it('default', function()
        util.setup('demo/heading_code.md')

        local expected = {}

        -- Headings 1 through 6 (minus 2)
        vim.list_extend(expected, util.heading(0, 1))
        vim.list_extend(expected, util.heading(2, 3))
        vim.list_extend(expected, util.heading(4, 4))
        vim.list_extend(expected, util.heading(6, 5))
        vim.list_extend(expected, util.heading(8, 6))

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
