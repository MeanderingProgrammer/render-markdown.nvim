local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('box_dash_quote.md', function()
    async_tests.it('default', function()
        util.setup('demo/box_dash_quote.md')

        local expected = {}

        -- Heading
        vim.list_extend(expected, util.heading(0, 1))

        -- Checkboxes
        vim.list_extend(expected, util.checkbox(2, ' 󰄱 ', 'RenderMarkdownUnchecked', false))
        vim.list_extend(expected, util.checkbox(3, ' 󰱒 ', 'RenderMarkdownChecked', false))
        vim.list_extend(expected, util.checkbox(4, ' 󰥔 ', 'RenderMarkdownTodo', true))

        -- Line break
        vim.list_extend(expected, {
            {
                row = { 6 },
                col = { 0 },
                virt_text = { { string.rep('─', vim.opt.columns:get()), 'RenderMarkdownDash' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Quote lines
        vim.list_extend(expected, {
            util.quote(8, '  %s ', 'Quote'),
            util.quote(9, '  %s ', 'Quote'),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
