---@module 'luassert'

local util = require('tests.util')

describe('list_table.md', function()
    it('default', function()
        util.setup('demo/list_table.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.link(row:get(), 20, 47, 'web'),
            util.bullet(row:increment(), 0, 1),
            util.inline_code(row:get(), 20, 28),
            util.bullet(row:increment(), 2, 2, 2),
            util.bullet(row:increment(), 4, 2),
            util.bullet(row:increment(), 6, 3),
            util.bullet(row:increment(), 8, 4),
            util.bullet(row:increment(), 10, 1),
            util.bullet(row:increment(), 0, 1),
            util.link(row:get(), 20, 45, 'link'),
        })

        vim.list_extend(expected, util.heading(row:increment(2), 1))

        vim.list_extend(expected, util.heading(row:increment(5), 1))

        vim.list_extend(expected, {
            util.table_border(row:increment(2), true, { 8, 15, 7, 6 }),
            util.table_pipe(row:get(), 0, true),
            util.inline_code(row:get(), 2, 8),
            util.table_padding(row:get(), 9, 2),
            util.table_pipe(row:get(), 9, true),
            util.table_padding(row:get(), 11, 3),
            util.conceal(row:get(), 24, 25),
            util.table_pipe(row:get(), 25, true),
            util.table_pipe(row:get(), 33, true),
            util.table_pipe(row:get(), 40, true),
        })
        table.insert(expected, util.table_delimiter(row:increment(), { { 1, 7 }, { 1, 13, 1 }, { 6, 1 }, 6 }))
        vim.list_extend(expected, {
            util.table_pipe(row:increment(), 0, false),
            util.inline_code(row:get(), 2, 8),
            util.table_padding(row:get(), 9, 2),
            util.table_pipe(row:get(), 9, false),
            util.table_padding(row:get(), 11, 4),
            util.table_pipe(row:get(), 25, false),
            util.table_pipe(row:get(), 33, false),
            util.table_pipe(row:get(), 40, false),
        })
        vim.list_extend(expected, {
            util.table_pipe(row:increment(), 0, false),
            util.table_pipe(row:get(), 9, false),
            util.table_padding(row:get(), 11, 3),
            util.link(row:get(), 11, 24, 'link'),
            util.table_padding(row:get(), 25, 4),
            util.table_pipe(row:get(), 25, false),
            util.table_padding(row:get(), 27, 1),
            util.conceal(row:get(), 32, 33),
            util.table_pipe(row:get(), 33, false),
            util.table_pipe(row:get(), 40, false),
            util.table_border(row:get(), false, { 8, 15, 7, 6 }),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
