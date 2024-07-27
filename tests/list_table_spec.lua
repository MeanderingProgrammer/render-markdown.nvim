---@module 'luassert'
local util = require('tests.util')

describe('list_table.md', function()
    it('default', function()
        util.setup('demo/list_table.md')

        local expected = {}

        -- Unordered list
        vim.list_extend(expected, util.heading(0, 1))
        vim.list_extend(expected, {
            util.bullet(2, 0, 1), -- List Item 1
            util.link(2, 20, 47, false), -- List Item 1, link
            util.bullet(3, 0, 1), -- List Item 2
            util.inline_code(3, 20, 28), -- List Item 2, code
            util.bullet(4, 2, 2, 2), -- Nested List 1 Item 1
            util.bullet(5, 4, 2), -- Nested List 1 Item 2
            util.bullet(6, 6, 3), -- Nested List 2 Item 1
            util.bullet(7, 8, 4), -- Nested List 3 Item 1
            util.bullet(8, 10, 1), -- Nested List 4 Item 1
            util.bullet(9, 0, 1), -- List Item 3
            util.link(9, 20, 45, false), -- List Item 3, link
        })

        -- Ordered list
        vim.list_extend(expected, util.heading(11, 1))

        -- Table
        vim.list_extend(expected, util.heading(16, 1))
        vim.list_extend(expected, {
            -- Heading
            util.table_pipe(18, 0, true), -- Pipe 1
            util.table_border(18, 'above', { 8, 15, 7, 6 }),
            util.inline_code(18, 2, 8), -- Inline code
            util.table_padding(18, 8, 2), -- Padding 1
            util.table_pipe(18, 9, true), -- Pipe 2
            util.table_padding(18, 24, 2), -- Padding 2
            util.table_pipe(18, 25, true), -- Pipe 3
            util.table_pipe(18, 33, true), -- Pipe 4
            util.table_pipe(18, 40, true), -- Pipe 5
            -- Delimiter
            {
                row = { 19, 19 },
                col = { 0, 41 },
                virt_text = {
                    {
                        '├━───────┼───────━───────┼──────━┼──────┤',
                        'RenderMarkdownTableHead',
                    },
                },
                virt_text_pos = 'overlay',
            },
            -- Row 1
            util.table_pipe(20, 0, false), -- Pipe 1
            util.inline_code(20, 2, 8), -- Inline code
            util.table_padding(20, 8, 2), -- Padding 1
            util.table_pipe(20, 9, false), -- Pipe 2
            util.table_padding(20, 24, 4), -- Padding 2
            util.table_pipe(20, 25, false), -- Pipe 3
            util.table_pipe(20, 33, false), -- Pipe 4
            util.table_pipe(20, 40, false), -- Pipe 5
            -- Row 2
            util.table_pipe(21, 0, false), -- Pipe 1
            util.table_border(21, 'below', { 8, 15, 7, 6 }),
            util.table_pipe(21, 9, false), -- Pipe 2
            util.link(21, 11, 24, false), -- Link
            util.table_padding(21, 24, 7), -- Padding 1
            util.table_pipe(21, 25, false), -- Pipe 3
            util.table_pipe(21, 33, false), -- Pipe 4
            util.table_pipe(21, 40, false), -- Pipe 5
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
