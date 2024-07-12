local async_tests = require('plenary.async.tests')
local util = require('tests.util')

local function conceal_escape(namespace, root, buf)
    local query = vim.treesitter.query.parse('markdown_inline', '(backslash_escape) @escape')
    for _, node in query:iter_captures(root, buf) do
        local start_row, start_col, end_row, _ = node:range()
        vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
            end_row = end_row,
            end_col = start_col + 1,
            conceal = '',
        })
    end
end

---@param row integer
---@param col integer
---@return render.md.MarkInfo
local function backslash(row, col)
    return {
        row = { row, row },
        col = { col, col + 1 },
        conceal = '',
    }
end

async_tests.describe('custom_handler.md', function()
    async_tests.it('default', function()
        util.setup('tests/data/custom_handler.md')

        local expected = {}

        -- Heading / inline code
        vim.list_extend(expected, util.heading(0, 1))
        vim.list_extend(expected, { util.inline_code(0, 9, 18) })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    async_tests.it('custom override', function()
        util.setup('tests/data/custom_handler.md', {
            custom_handlers = {
                markdown_inline = {
                    render = conceal_escape,
                },
            },
        })

        local expected = {}

        -- Heading / no inline code
        vim.list_extend(expected, util.heading(0, 1))

        -- Backslash escapes
        vim.list_extend(expected, { backslash(2, 0), backslash(2, 7) })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    async_tests.it('custom extends', function()
        util.setup('tests/data/custom_handler.md', {
            custom_handlers = {
                markdown_inline = {
                    render = conceal_escape,
                    extends = true,
                },
            },
        })

        local expected = {}

        -- Heading / inline code
        vim.list_extend(expected, util.heading(0, 1))
        vim.list_extend(expected, { util.inline_code(0, 9, 18) })

        -- Backslash escapes
        vim.list_extend(expected, { backslash(2, 0), backslash(2, 7) })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
