local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('list_table.md', function()
    async_tests.it('default', function()
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
        })

        -- Ordered list
        vim.list_extend(expected, util.heading(11, 1))

        -- Table
        vim.list_extend(expected, util.heading(17, 1))
        vim.list_extend(expected, {
            util.table_pipe(19, 0, true), -- Heading pipe 1
            util.table_border(19, 'above', { 18, 20 }),
            util.inline_code(19, 2, 18), -- Inline code in heading
            util.table_padding(19, 18, 2), -- Heading padding 1
            util.table_pipe(19, 19, true), -- Heading pipe 2
            util.table_padding(19, 39, 2), -- Heading padding 2
            util.table_pipe(19, 40, true), -- Heading pipe 2
            util.table_border(20, 'delimiter', { 18, 20 }),
            util.table_pipe(21, 0, false), -- Row 1 pipe 1
            util.table_pipe(21, 19, false), -- Row 1 pipe 2
            util.table_padding(21, 39, 4), -- Row 1 padding 2
            util.table_pipe(21, 40, false), -- Row 1 pipe 3
            util.table_pipe(22, 0, false), -- Row 2 pipe 1
            util.table_border(22, 'below', { 18, 20 }),
            util.inline_code(22, 2, 15), -- Row 2 inline code
            util.table_padding(22, 18, 2), -- Row 2 padding 1
            util.table_pipe(22, 19, false), -- Row 2 pipe 2
            util.link(22, 21, 39, false), -- Row 2 link
            util.table_padding(22, 39, 7), -- Row 2 padding 2
            util.table_pipe(22, 40, false), -- Row 2 pipe 3
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
