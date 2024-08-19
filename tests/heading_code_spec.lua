---@module 'luassert'

local util = require('tests.util')

describe('heading_code.md', function()
    it('default', function()
        util.setup('demo/heading_code.md')

        local expected = {}

        vim.list_extend(expected, {
            util.heading(0, 1),
            util.heading(2, 3),
            util.heading(4, 4),
            util.heading(6, 5),
            util.heading(8, 6),
        })

        table.insert(expected, util.link(10, 0, 21, 'image'))

        vim.list_extend(expected, {
            util.code_row(12, 0),
            util.code_language(12, 3, 9, 'python'),
        })
        for i = 13, 21 do
            table.insert(expected, util.code_row(i, 0))
        end
        table.insert(expected, util.code_below(22, 0))

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
