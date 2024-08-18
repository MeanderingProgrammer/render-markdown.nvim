---@module 'luassert'

local util = require('tests.util')

describe('heading_code.md', function()
    it('default', function()
        util.setup('demo/heading_code.md')

        local expected = {}

        -- Headings 1 through 6 (minus 2)
        vim.list_extend(expected, util.heading(0, 1))
        vim.list_extend(expected, util.heading(2, 3))
        vim.list_extend(expected, util.heading(4, 4))
        vim.list_extend(expected, util.heading(6, 5))
        vim.list_extend(expected, util.heading(8, 6))

        vim.list_extend(expected, {
            util.link(10, 0, 21, 'image'), -- Image link
            util.code_block_row(12, 0), -- Code block start
        })
        vim.list_extend(expected, util.code_language(12, 3, 9, 'python'))
        for i = 13, 21 do
            table.insert(expected, util.code_block_row(i, 0))
        end
        table.insert(expected, util.code_below(22, 0))

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
