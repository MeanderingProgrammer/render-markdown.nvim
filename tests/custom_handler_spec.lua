---@module 'luassert'

local util = require('tests.util')

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
local function parse_conceal_escape(root, buf)
    local marks = {}
    local query = vim.treesitter.query.parse('markdown_inline', '(backslash_escape) @escape')
    for _, node in query:iter_captures(root, buf) do
        local start_row, start_col, end_row, _ = node:range()
        ---@type render.md.Mark
        local mark = {
            conceal = true,
            start_row = start_row,
            start_col = start_col,
            opts = {
                end_row = end_row,
                end_col = start_col + 1,
                conceal = '',
            },
        }
        table.insert(marks, mark)
    end
    return marks
end

---@param row integer
---@param col integer
---@return render.md.MarkInfo
local function backslash(row, col)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { col, col + 1 },
        conceal = '',
    }
end

describe('custom_handler.md', function()
    it('default', function()
        util.setup('tests/data/custom_handler.md')

        local expected, row = {}, util.row()
        vim.list_extend(expected, {
            util.heading(row:get(), 1), -- Heading
            util.inline_code(row:increment(2), 0, 8), -- Inline code
            {}, -- No backslash escapes
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    it('custom parse override', function()
        util.setup('tests/data/custom_handler.md', {
            custom_handlers = {
                markdown_inline = {
                    parse = parse_conceal_escape,
                },
            },
        })

        local expected, row = {}, util.row()
        vim.list_extend(expected, {
            util.heading(row:get(), 1), -- Heading
            {}, -- No inline code
            { backslash(row:increment(4), 0), backslash(row:get(), 7) }, -- Backslash escapes
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    it('custom parse extend', function()
        util.setup('tests/data/custom_handler.md', {
            custom_handlers = {
                markdown_inline = {
                    parse = parse_conceal_escape,
                    extends = true,
                },
            },
        })

        local expected, row = {}, util.row()
        vim.list_extend(expected, {
            util.heading(row:get(), 1), -- Heading
            util.inline_code(row:increment(2), 0, 8), -- Inline code
            { backslash(row:increment(2), 0), backslash(row:get(), 7) }, -- Backslash escapes
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
