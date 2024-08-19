---@module 'luassert'

local util = require('tests.util')

describe('code.md', function()
    it('default', function()
        util.setup('tests/data/code.md')

        local expected = {}

        vim.list_extend(expected, util.heading(0, 1))

        vim.list_extend(expected, {
            util.bullet(2, 0, 1),
            util.code_row(4, 2),
            util.code_language(4, 5, 8, 'lua'),
            util.code_row(5, 2),
            util.code_row(6, 2),
            util.code_below(7, 2),
        })

        vim.list_extend(expected, {
            util.bullet(9, 0, 1),
            util.code_row(11, 2),
            util.code_language(11, 5, 8, 'lua'),
            util.code_row(12, 2),
            util.code_row(13, 0),
            util.padding(13, 2),
            util.code_row(14, 2),
            util.code_below(15, 2),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
