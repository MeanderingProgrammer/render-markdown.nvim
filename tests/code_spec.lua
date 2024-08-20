---@module 'luassert'

local util = require('tests.util')

describe('code.md', function()
    it('default', function()
        util.setup('tests/data/code.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_row(row:increment(2), 2),
            util.code_language(row:get(), 5, 8, 'lua'),
            util.code_row(row:increment(), 2),
            util.code_row(row:increment(), 2),
            util.code_below(row:increment(), 2),
        })

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_row(row:increment(2), 2),
            util.code_language(row:get(), 5, 8, 'lua'),
            util.code_row(row:increment(), 2),
            util.code_row(row:increment(), 0),
            util.padding(row:get(), 2),
            util.code_row(row:increment(), 2),
            util.code_below(row:increment(), 2),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
