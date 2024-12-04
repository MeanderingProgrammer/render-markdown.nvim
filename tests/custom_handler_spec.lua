---@module 'luassert'

local util = require('tests.util')

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
local function conceal_escape(root, buf)
    local marks, query = {}, vim.treesitter.query.parse('markdown_inline', '(backslash_escape) @escape')
    for _, node in query:iter_captures(root, buf) do
        local start_row, start_col, end_row, _ = node:range()
        table.insert(marks, {
            conceal = true,
            start_row = start_row,
            start_col = start_col,
            opts = { end_row = end_row, end_col = start_col + 1, conceal = '' },
        })
    end
    return marks
end

describe('custom_handler.md', function()
    it('default', function()
        util.setup('tests/data/custom_handler.md')

        local expected, row = {}, util.row()
        vim.list_extend(expected, {
            util.heading(row:get(), 1), -- Heading
            util.highlight(row:increment(2), 0, 8, 'CodeInline'), -- Inline code
            {}, -- No backslash escapes
        })

        util.assert_view(expected, {
            '󰫎   1 󰲡 Heading',
            '    2',
            '    3 Inline code',
            '    4',
            '    5 \\$1.50 \\$3.55',
        })
    end)

    it('custom conceal override', function()
        util.setup('tests/data/custom_handler.md', {
            custom_handlers = {
                markdown_inline = { parse = conceal_escape },
            },
        })

        local expected, row = {}, util.row()
        vim.list_extend(expected, {
            util.heading(row:get(), 1), -- Heading
            {}, -- No inline code
            { util.conceal(row:increment(4), 0, 1), util.conceal(row:get(), 7, 8) }, -- Backslash escapes
        })

        util.assert_view(expected, {
            '󰫎   1 󰲡 Heading',
            '    2',
            '    3 Inline code',
            '    4',
            '    5 $1.50 $3.55',
        })
    end)

    it('custom conceal extend', function()
        util.setup('tests/data/custom_handler.md', {
            custom_handlers = {
                markdown_inline = { extends = true, parse = conceal_escape },
            },
        })

        local expected, row = {}, util.row()
        vim.list_extend(expected, {
            util.heading(row:get(), 1), -- Heading
            util.highlight(row:increment(2), 0, 8, 'CodeInline'), -- Inline code
            { util.conceal(row:increment(2), 0, 1), util.conceal(row:get(), 7, 8) }, -- Backslash escapes
        })

        util.assert_view(expected, {
            '󰫎   1 󰲡 Heading',
            '    2',
            '    3 Inline code',
            '    4',
            '    5 $1.50 $3.55',
        })
    end)
end)
