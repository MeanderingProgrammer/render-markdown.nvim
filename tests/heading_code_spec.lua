---@module 'luassert'

local util = require('tests.util')

describe('heading_code.md', function()
    it('default', function()
        util.setup('demo/heading_code.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, {
            util.heading(row:get(), 1),
            util.heading(row:increment(2), 3),
            util.heading(row:increment(2), 4),
            util.heading(row:increment(2), 5),
            util.heading(row:increment(2), 6),
        })

        table.insert(expected, util.link(row:increment(2), 0, 21, 'image'))

        table.insert(expected, util.code_language(row:increment(2), 0, 'python'))
        for _ = 13, 21 do
            table.insert(expected, util.code_row(row:increment(), 0))
        end
        table.insert(expected, util.code_below(row:increment(), 0))

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
