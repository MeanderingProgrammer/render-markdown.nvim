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
        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))
        -- Inline code
        marks:add(row:inc(), row:get(), 0, 8, util.highlight('code'))
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
        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))
        -- No inline code
        -- Backslash escapes
        marks:add(row:inc(3), row:get(), 0, 1, util.conceal())
        marks:add(row:get(), row:get(), 7, 8, util.conceal())
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
        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))
        -- Inline code
        marks:add(row:inc(), row:get(), 0, 8, util.highlight('code'))
        -- Backslash escapes
        marks:add(row:inc(2), row:get(), 0, 1, util.conceal())
        marks:add(row:get(), row:get(), 7, 8, util.conceal())
        util.assert_view(marks, {
            '󰫎   1 󰲡 Heading',
            '    2',
            '    3 Inline code',
            '    4',
            '    5 $1.50 $3.55',
        })
    end)
end)
