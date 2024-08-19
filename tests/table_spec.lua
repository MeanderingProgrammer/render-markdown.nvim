---@module 'luassert'

local util = require('tests.util')

describe('table.md', function()
    it('default', function()
        util.setup('tests/data/table.md')

        local expected = {}

        vim.list_extend(expected, {
            util.heading(0, 1),
            util.table_pipe(2, 0, true),
            util.table_border(2, 'above', { 11, 24 }),
            util.table_pipe(2, 12, true),
            util.inline_code(2, 14, 25),
            util.table_padding(2, 36, 2),
            util.table_pipe(2, 37, true),
            util.table_border(3, 'delimiter', { 11, 24 }),
            util.table_pipe(4, 0, false),
            util.table_border(4, 'below', { 11, 24 }),
            util.inline_code(4, 2, 12),
            util.table_padding(4, 12, 2),
            util.table_pipe(4, 13, false),
            util.link(4, 15, 38, 'web'),
            util.table_padding(4, 38, 16),
            util.table_pipe(4, 39, false),
        })

        vim.list_extend(expected, {
            util.heading(6, 1),
            util.table_pipe(8, 0, true),
            util.table_border(8, 'above', { 11, 11 }),
            util.table_pipe(8, 12, true),
            util.table_pipe(8, 24, true),
            util.table_border(9, 'delimiter', { 11, 11 }),
            util.table_pipe(10, 0, false),
            util.table_border(10, 'below', { 11, 11 }),
            util.table_pipe(10, 12, false),
            util.table_pipe(10, 24, false),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    it('raw', function()
        util.setup('tests/data/table.md', { pipe_table = { cell = 'raw' } })

        local expected = {}

        vim.list_extend(expected, {
            util.heading(0, 1),
            util.table_pipe(2, 0, true),
            util.table_pipe(2, 12, true),
            util.inline_code(2, 14, 25),
            util.table_pipe(2, 37, true),
            util.table_border(3, 'delimiter', { 11, 24 }),
            util.table_pipe(4, 0, false),
            util.inline_code(4, 2, 12),
            util.table_pipe(4, 13, false),
            util.link(4, 15, 38, 'web'),
            util.table_pipe(4, 39, false),
        })

        vim.list_extend(expected, {
            util.heading(6, 1),
            util.table_pipe(8, 0, true),
            util.table_border(8, 'above', { 11, 11 }),
            util.table_pipe(8, 12, true),
            util.table_pipe(8, 24, true),
            util.table_border(9, 'delimiter', { 11, 11 }),
            util.table_pipe(10, 0, false),
            util.table_border(10, 'below', { 11, 11 }),
            util.table_pipe(10, 12, false),
            util.table_pipe(10, 24, false),
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

        local expected = {}

        vim.list_extend(expected, {
            util.heading(0, 1),
            table_row(2, 38, '│ Heading 1 │ `Heading 2`            │', true),
            util.table_border(2, 'above', { 11, 24 }),
            util.inline_code(2, 14, 25),
            util.table_border(3, 'delimiter', { 11, 24 }),
            table_row(4, 40, '│ `Item 行` │ [link](https://行.com) │', false),
            util.table_border(4, 'below', { 11, 24 }),
            util.inline_code(4, 2, 12),
            util.link(4, 15, 38, 'web'),
        })

        vim.list_extend(expected, {
            util.heading(6, 1),
            table_row(8, 25, '│ Heading 1 │ Heading 2 │', true),
            util.table_border(8, 'above', { 11, 11 }),
            util.table_border(9, 'delimiter', { 11, 11 }),
            table_row(10, 25, '│ Item 1    │ Item 2    │', false),
            util.table_border(10, 'below', { 11, 11 }),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
