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
            util.highlight(row:get(), 14, 25, 'CodeInline'),
            util.conceal(row:get(), 26, 37),
            util.table_pipe(row:get(), 37, true),
            util.table_delimiter(row:increment(), { 11, { 23, 1 } }),
            util.table_pipe(row:increment(), 0, false),
            util.highlight(row:get(), 2, 12, 'CodeInline'),
            util.table_padding(row:get(), 13, 2),
            util.table_pipe(row:get(), 13, false),
            util.table_padding(row:get(), 15, 16),
            util.link(row:get(), 15, 38, 'web'),
            util.table_pipe(row:get(), 39, false),
            util.table_pipe(row:increment(), 0, false),
            util.table_padding(row:get(), 12, 8),
            util.table_pipe(row:get(), 12, false),
            util.table_padding(row:get(), 14, 16),
            util.inline_highlight(row:get(), 14, 25),
            util.conceal(row:get(), 26, 38),
            util.table_pipe(row:get(), 38, false),
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

        util.assert_view(expected, {
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬────────────────────────┐',
            '    3 │ Heading 1 │              Heading 2 │',
            '    4 ├───────────┼───────────────────────━┤',
            '    5 │ Item 行   │                 󰖟 link │',
            '    6 │ 1         │                 Itém 2 │',
            '      └───────────┴────────────────────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)

    it('trimmed', function()
        util.setup('tests/data/table.md', { pipe_table = { cell = 'trimmed' } })

        local expected, row = {}, util.row()

        vim.list_extend(expected, {
            util.heading(row:get(), 1),
            util.table_border(row:increment(2), true, { 11, 11 }),
            util.table_pipe(row:get(), 0, true),
            util.table_pipe(row:get(), 12, true),
            util.highlight(row:get(), 14, 25, 'CodeInline'),
            util.conceal(row:get(), 26, 37),
            util.table_pipe(row:get(), 37, true),
            util.table_delimiter(row:increment(), { 11, { 10, 1 } }, 13),
            util.table_pipe(row:increment(), 0, false),
            util.highlight(row:get(), 2, 12, 'CodeInline'),
            util.table_padding(row:get(), 13, 2),
            util.table_pipe(row:get(), 13, false),
            util.table_padding(row:get(), 15, 3),
            util.link(row:get(), 15, 38, 'web'),
            util.table_pipe(row:get(), 39, false),
            util.table_pipe(row:increment(), 0, false),
            util.table_padding(row:get(), 12, 8),
            util.table_pipe(row:get(), 12, false),
            util.table_padding(row:get(), 14, 3),
            util.inline_highlight(row:get(), 14, 25),
            util.conceal(row:get(), 26, 38),
            util.table_pipe(row:get(), 38, false),
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

        util.assert_view(expected, {
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬───────────┐',
            '    3 │ Heading 1 │ Heading 2 │',
            '    4 ├───────────┼──────────━┤',
            '    5 │ Item 行   │    󰖟 link │',
            '    6 │ 1         │    Itém 2 │',
            '      └───────────┴───────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)

    it('raw', function()
        util.setup('tests/data/table.md', { pipe_table = { cell = 'raw' } })

        local expected, row = {}, util.row()

        vim.list_extend(expected, {
            util.heading(row:get(), 1),
            util.table_pipe(row:increment(2), 0, true),
            util.table_pipe(row:get(), 12, true),
            util.highlight(row:get(), 14, 25, 'CodeInline'),
            util.table_pipe(row:get(), 37, true),
            util.table_delimiter(row:increment(), { 11, { 23, 1 } }),
            util.table_pipe(row:increment(), 0, false),
            util.highlight(row:get(), 2, 12, 'CodeInline'),
            util.table_pipe(row:get(), 13, false),
            util.link(row:get(), 15, 38, 'web'),
            util.table_pipe(row:get(), 39, false),
            util.table_pipe(row:increment(), 0, false),
            util.table_pipe(row:get(), 12, false),
            util.inline_highlight(row:get(), 14, 25),
            util.table_pipe(row:get(), 38, false),
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

        util.assert_view(expected, {
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '    3 │ Heading 1 │ Heading 2            │',
            '    4 ├───────────┼───────────────────────━┤',
            '    5 │ Item 行 │ 󰖟 link │',
            '    6 │ 1 │ Itém 2             │',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
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
            util.highlight(row:get(), 14, 25, 'CodeInline'),
            util.table_delimiter(row:increment(), { 11, { 23, 1 } }),
            table_row(row:increment(), 40, '│ `Item 行` │ [link](https://行.com) │', false),
            util.highlight(row:get(), 2, 12, 'CodeInline'),
            util.link(row:get(), 15, 38, 'web'),
            table_row(row:increment(), 39, '│ &lt;1&gt; │ ==Itém 2==             │', false),
            util.inline_highlight(row:get(), 14, 25),
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

        util.assert_view(expected, {
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬────────────────────────┐',
            '    3 │ Heading 1 │ `Heading 2`            │',
            '    4 ├───────────┼───────────────────────━┤',
            '    5 │ `Item 行` │ [link](https://行.com) │',
            '    6 │ &lt;1&gt; │ ==Itém 2==             │',
            '      └───────────┴────────────────────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)
end)
