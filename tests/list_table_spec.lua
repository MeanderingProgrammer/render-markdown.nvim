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
            util.table_pipe(row:increment(2), 0, true),
            util.table_border(row:get(), 'above', { 8, 15, 7, 6 }),
            util.inline_code(row:get(), 2, 8),
            util.table_padding(row:get(), 8, 2),
            util.table_pipe(row:get(), 9, true),
            util.table_padding(row:get(), 24, 2),
            util.table_pipe(row:get(), 25, true),
            util.table_pipe(row:get(), 33, true),
            util.table_pipe(row:get(), 40, true),
        })
        vim.list_extend(expected, {
            delimiter(
                row:increment(),
                '├━───────┼───────━───────┼──────━┼──────┤'
            ),
        })
        vim.list_extend(expected, {
            util.table_pipe(row:increment(), 0, false),
            util.inline_code(row:get(), 2, 8),
            util.table_padding(row:get(), 8, 2),
            util.table_pipe(row:get(), 9, false),
            util.table_padding(row:get(), 24, 4),
            util.table_pipe(row:get(), 25, false),
            util.table_pipe(row:get(), 33, false),
            util.table_pipe(row:get(), 40, false),
        })
        vim.list_extend(expected, {
            util.table_pipe(row:increment(), 0, false),
            util.table_border(row:get(), 'below', { 8, 15, 7, 6 }),
            util.table_pipe(row:get(), 9, false),
            util.link(row:get(), 11, 24, 'link'),
            util.table_padding(row:get(), 24, 7),
            util.table_pipe(row:get(), 25, false),
            util.table_pipe(row:get(), 33, false),
            util.table_pipe(row:get(), 40, false),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
