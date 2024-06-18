local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('latex.md', function()
    async_tests.it('default', function()
        -- TODO: mock interaction with latex2text
        util.setup('demo/latex.md')

        local expected = {}

        -- Heading
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

        vim.list_extend(expected, {
            -- Inline
            {
                row = { 2, 2 },
                col = { 0, 21 },
                virt_lines = { { { '√(3x-1)+(1+x)^2', '@markup.math' } } },
                virt_lines_above = true,
            },
            -- Block
            {
                row = { 4, 7 },
                col = { 0, 2 },
                virt_lines = {
                    { { 'f(x,y) = x + √(y)', '@markup.math' } },
                    { { 'f(x,y) = √(y) + x^2/4y', '@markup.math' } },
                },
                virt_lines_above = true,
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
