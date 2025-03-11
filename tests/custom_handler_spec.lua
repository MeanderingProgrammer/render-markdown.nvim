---@module 'luassert'

local util = require('tests.util')

---@param ctx render.md.HandlerContext
---@return render.md.Mark[]
local function conceal_escape(ctx)
    local marks, query = {}, vim.treesitter.query.parse('markdown_inline', '(backslash_escape) @escape')
    for _, node in query:iter_captures(ctx.root, ctx.buf) do
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

        local marks, row = util.marks(), util.row()
        -- Heading
        marks:extend(util.heading(row:get(), 1))
        -- Inline code
        marks:add(util.highlight(row:inc(2), { 0, 8 }, 'code'))
        -- No backslash escapes
        util.assert_view(marks, {
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

        local marks, row = util.marks(), util.row()
        -- Heading
        marks:extend(util.heading(row:get(), 1))
        -- No inline code
        -- Backslash escapes
        marks:add(util.conceal(row:inc(4), { 0, 1 }))
        marks:add(util.conceal(row:get(), { 7, 8 }))
        util.assert_view(marks, {
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

        local marks, row = util.marks(), util.row()
        -- Heading
        marks:extend(util.heading(row:get(), 1))
        -- Inline code
        marks:add(util.highlight(row:inc(2), { 0, 8 }, 'code'))
        -- Backslash escapes
        marks:add(util.conceal(row:inc(2), { 0, 1 }))
        marks:add(util.conceal(row:get(), { 7, 8 }))
        util.assert_view(marks, {
            '󰫎   1 󰲡 Heading',
            '    2',
            '    3 Inline code',
            '    4',
            '    5 $1.50 $3.55',
        })
    end)
end)
