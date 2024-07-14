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

        vim.list_extend(expected, {
            util.link(10, 0, 21, true), -- Image link
            util.code_block(12, 22), -- Code block
        })
        vim.list_extend(expected, util.code_language(12, 3, 9, '󰌠 ', 'python', 'MiniIconsYellow'))
        vim.list_extend(expected, { util.code_below(22, 0) })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
