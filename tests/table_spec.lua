---@module 'luassert'

local util = require('tests.util')

describe('table.md', function()
    it('default', function()
        util.setup('tests/data/table.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, {
            util.heading(row:get(), 1),
            util.table_border(row:increment(2), true, { 11, 24 }),
            util.table_pipe(row:get(), 0, true),
            util.table_pipe(row:get(), 12, true),
            util.table_padding(row:get(), 14, 13),
            util.inline_code(row:get(), 14, 25),
            util.conceal(row:get(), 26, 37),
            util.table_pipe(row:get(), 37, true),
            util.table_delimiter(row:increment(), { 11, { 23, 1 } }),
            util.table_pipe(row:increment(), 0, false),
            util.inline_code(row:get(), 2, 12),
            util.table_padding(row:get(), 13, 2),
            util.table_pipe(row:get(), 13, false),
            util.table_padding(row:get(), 15, 16),
            util.link(row:get(), 15, 38, 'web'),
            util.table_pipe(row:get(), 39, false),
            util.table_border(row:get(), false, { 11, 24 }),
        })

        vim.list_extend(expected, {
            util.heading(row:increment(2), 1),
            util.table_border(row:increment(2), true, { 11, 11 }),
            util.table_pipe(row:get(), 0, true),
            util.table_pipe(row:get(), 12, true),
            util.table_pipe(row:get(), 24, true),
            util.table_delimiter(row:increment(), { 11, 11 }),
            util.table_pipe(row:increment(), 0, false),
            util.table_pipe(row:get(), 12, false),
            util.table_pipe(row:get(), 24, false),
            util.table_border(row:get(), false, { 11, 11 }),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    it('trimmed', function()
        util.setup('tests/data/table.md', { pipe_table = { cell = 'trimmed' } })

        local expected, row = {}, util.row()

        vim.list_extend(expected, {
            util.heading(row:get(), 1),
            util.table_border(row:increment(2), true, { 11, 11 }),
            util.table_pipe(row:get(), 0, true),
            util.table_pipe(row:get(), 12, true),
            util.inline_code(row:get(), 14, 25),
            util.conceal(row:get(), 26, 37),
            util.table_pipe(row:get(), 37, true),
            util.table_delimiter(row:increment(), { 11, { 10, 1 } }, 13),
            util.table_pipe(row:increment(), 0, false),
            util.inline_code(row:get(), 2, 12),
            util.table_padding(row:get(), 13, 2),
            util.table_pipe(row:get(), 13, false),
            util.table_padding(row:get(), 15, 3),
            util.link(row:get(), 15, 38, 'web'),
            util.table_pipe(row:get(), 39, false),
            util.table_border(row:get(), false, { 11, 11 }),
        })

        vim.list_extend(expected, {
            util.heading(row:increment(2), 1),
            util.table_border(row:increment(2), true, { 11, 11 }),
            util.table_pipe(row:get(), 0, true),
            util.table_pipe(row:get(), 12, true),
            util.table_pipe(row:get(), 24, true),
            util.table_delimiter(row:increment(), { 11, 11 }),
            util.table_pipe(row:increment(), 0, false),
            util.table_pipe(row:get(), 12, false),
            util.table_pipe(row:get(), 24, false),
            util.table_border(row:get(), false, { 11, 11 }),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    it('raw', function()
        util.setup('tests/data/table.md', { pipe_table = { cell = 'raw' } })

        local expected, row = {}, util.row()

        vim.list_extend(expected, {
            util.heading(row:get(), 1),
            util.table_pipe(row:increment(2), 0, true),
            util.table_pipe(row:get(), 12, true),
            util.inline_code(row:get(), 14, 25),
            util.table_pipe(row:get(), 37, true),
            util.table_delimiter(row:increment(), { 11, { 23, 1 } }),
            util.table_pipe(row:increment(), 0, false),
            util.inline_code(row:get(), 2, 12),
            util.table_pipe(row:get(), 13, false),
            util.link(row:get(), 15, 38, 'web'),
            util.table_pipe(row:get(), 39, false),
        })

        vim.list_extend(expected, {
            util.heading(row:increment(2), 1),
            util.table_border(row:increment(2), true, { 11, 11 }),
            util.table_pipe(row:get(), 0, true),
            util.table_pipe(row:get(), 12, true),
            util.table_pipe(row:get(), 24, true),
            util.table_delimiter(row:increment(), { 11, 11 }),
            util.table_pipe(row:increment(), 0, false),
            util.table_pipe(row:get(), 12, false),
            util.table_pipe(row:get(), 24, false),
            util.table_border(row:get(), false, { 11, 11 }),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    it('overlay', function()
        ---@param row integer
        ---@param col integer
        ---@param value string
        ---@param head boolean
        ---@return render.md.MarkInfo
        local function table_row(row, col, value, head)
            local highlight = head and 'TableHead' or 'TableRow'
            ---@type render.md.MarkInfo
            return {
                row = { row, row },
                col = { 0, col },
                virt_text = { { value, util.hl(highlight) } },
                virt_text_pos = 'overlay',
            }
        end

        util.setup('tests/data/table.md', { pipe_table = { cell = 'overlay' } })

        local expected, row = {}, util.row()

        vim.list_extend(expected, {
            util.heading(row:get(), 1),
            util.table_border(row:increment(2), true, { 11, 24 }),
            table_row(row:get(), 38, '│ Heading 1 │ `Heading 2`            │', true),
            util.inline_code(row:get(), 14, 25),
            util.table_delimiter(row:increment(), { 11, { 23, 1 } }),
            table_row(row:increment(), 40, '│ `Item 行` │ [link](https://行.com) │', false),
            util.inline_code(row:get(), 2, 12),
            util.link(row:get(), 15, 38, 'web'),
            util.table_border(row:get(), false, { 11, 24 }),
        })

        vim.list_extend(expected, {
            util.heading(row:increment(2), 1),
            util.table_border(row:increment(2), true, { 11, 11 }),
            table_row(row:get(), 25, '│ Heading 1 │ Heading 2 │', true),
            util.table_delimiter(row:increment(), { 11, 11 }),
            table_row(row:increment(), 25, '│ Item 1    │ Item 2    │', false),
            util.table_border(row:get(), false, { 11, 11 }),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
