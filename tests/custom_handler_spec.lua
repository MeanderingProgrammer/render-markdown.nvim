---@module 'luassert'

local util = require('tests.util')

local lines = {
    '`Inline` code',
    '\\$1.50 \\$3.55',
}

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
local function conceal_escape(ctx)
    local marks = {} ---@type render.md.Mark[]
    local query = vim.treesitter.query.parse(
        'markdown_inline',
        '(backslash_escape) @escape'
    )
    for _, node in query:iter_captures(ctx.root, ctx.buf) do
        local start_row, start_col, end_row = node:range()
        marks[#marks + 1] = {
            conceal = true,
            start_row = start_row,
            start_col = start_col,
            opts = { end_row = end_row, end_col = start_col + 1, conceal = '' },
        }
    end
    return marks
end

describe('custom handler', function()
    it('default', function()
        util.setup.text(lines)
        -- inline code + no backslash escapes
        local marks = util.marks()
        marks:add({ 0, 0 }, { 0, 8 }, util.highlight('code'))
        util.assert_view(marks, {
            'Inline code',
            '\\$1.50 \\$3.55',
        })
    end)

    it('custom conceal override', function()
        util.setup.text(lines, {
            custom_handlers = {
                markdown_inline = { parse = conceal_escape },
            },
        })
        -- no inline code + backslash escapes
        local marks = util.marks()
        marks:add({ 1, 1 }, { 0, 1 }, util.conceal())
        marks:add({ 1, 1 }, { 7, 8 }, util.conceal())
        util.assert_view(marks, {
            'Inline code',
            '$1.50 $3.55',
        })
    end)

    it('custom conceal extend', function()
        util.setup.text(lines, {
            custom_handlers = {
                markdown_inline = { extends = true, parse = conceal_escape },
            },
        })
        -- inline code + backslash escapes
        local marks = util.marks()
        marks:add({ 0, 0 }, { 0, 8 }, util.highlight('code'))
        marks:add({ 1, 1 }, { 0, 1 }, util.conceal())
        marks:add({ 1, 1 }, { 7, 8 }, util.conceal())
        util.assert_view(marks, {
            'Inline code',
            '$1.50 $3.55',
        })
    end)
end)
