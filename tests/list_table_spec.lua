---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param text string
---@return render.md.MarkInfo
local function delimiter(row, text)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { 0, vim.fn.strdisplaywidth(text) },
        virt_text = { { text, util.hl('TableHead') } },
        virt_text_pos = 'overlay',
    }
end

describe('list_table.md', function()
    it('default', function()
        util.setup('demo/list_table.md')

        local expected = {}

        vim.list_extend(expected, util.heading(0, 1))

        vim.list_extend(expected, {
            util.bullet(2, 0, 1),
            util.link(2, 20, 47, 'web'),
            util.bullet(3, 0, 1),
            util.inline_code(3, 20, 28),
            util.bullet(4, 2, 2, 2),
            util.bullet(5, 4, 2),
            util.bullet(6, 6, 3),
            util.bullet(7, 8, 4),
            util.bullet(8, 10, 1),
            util.bullet(9, 0, 1),
            util.link(9, 20, 45, 'link'),
        })

        vim.list_extend(expected, util.heading(11, 1))

        vim.list_extend(expected, util.heading(16, 1))

        vim.list_extend(expected, {
            util.table_pipe(18, 0, true),
            util.table_border(18, 'above', { 8, 15, 7, 6 }),
            util.inline_code(18, 2, 8),
            util.table_padding(18, 8, 2),
            util.table_pipe(18, 9, true),
            util.table_padding(18, 24, 2),
            util.table_pipe(18, 25, true),
            util.table_pipe(18, 33, true),
            util.table_pipe(18, 40, true),
        })
        vim.list_extend(expected, {
            delimiter(
                19,
                '├━───────┼───────━───────┼──────━┼──────┤'
            ),
        })
        vim.list_extend(expected, {
            util.table_pipe(20, 0, false),
            util.inline_code(20, 2, 8),
            util.table_padding(20, 8, 2),
            util.table_pipe(20, 9, false),
            util.table_padding(20, 24, 4),
            util.table_pipe(20, 25, false),
            util.table_pipe(20, 33, false),
            util.table_pipe(20, 40, false),
        })
        vim.list_extend(expected, {
            util.table_pipe(21, 0, false),
            util.table_border(21, 'below', { 8, 15, 7, 6 }),
            util.table_pipe(21, 9, false),
            util.link(21, 11, 24, 'link'),
            util.table_padding(21, 24, 7),
            util.table_pipe(21, 25, false),
            util.table_pipe(21, 33, false),
            util.table_pipe(21, 40, false),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
