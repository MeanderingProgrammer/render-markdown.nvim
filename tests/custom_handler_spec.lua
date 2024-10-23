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

---@param root TSNode
---@param buf integer
---@return render.md.Mark[]
local function highlight_equal(root, buf)
    local marks = {}

    ---@param row { [1]: integer, [2]: integer }
    ---@param col { [1]: integer, [2]: integer }
    ---@param conceal? string
    ---@param hl_group? string
    local function append(row, col, conceal, hl_group)
        table.insert(marks, {
            conceal = row[1] == row[2],
            start_row = row[1],
            start_col = col[1],
            opts = { end_row = row[2], end_col = col[2], conceal = conceal, hl_group = hl_group },
        })
    end

    local text = vim.treesitter.get_node_text(root, buf)
    local top_row = root:range()

    ---@param index integer
    ---@return integer, integer
    local function row_col(index)
        local lines = vim.split(text:sub(1, index), '\n', { plain = true })
        return top_row + #lines - 1, #lines[#lines]
    end

    ---@type integer|nil
    local index = 1
    while index ~= nil do
        local start_index, end_index = text:find('(=)=[^=]+=(=)', index)
        if start_index ~= nil and end_index ~= nil then
            local start_row, start_col = row_col(start_index - 1)
            local end_row, end_col = row_col(end_index)
            -- Hide first 2 equal signs
            append({ start_row, start_row }, { start_col, start_col + 2 }, '', nil)
            -- Highlight contents
            append({ start_row, end_row }, { start_col, end_col }, nil, 'DiffDelete')
            -- Hide last 2 equal signs
            append({ end_row, end_row }, { end_col - 2, end_col }, '', nil)
            index = end_index + 1
        else
            index = nil
        end
    end

    return marks
end

---@param row { [1]: integer, [2]: integer }
---@param col { [1]: integer, [2]: integer }
---@return render.md.MarkInfo[]
local function highlight_equals(row, col)
    ---@type render.md.MarkInfo
    local highlight = {
        row = row,
        col = col,
        hl_eol = false,
        hl_group = 'DiffDelete',
    }
    return { util.conceal(row[1], col[1], col[1] + 2), highlight, util.conceal(row[2], col[2] - 2, col[2]) }
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

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
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
            util.inline_code(row:increment(2), 0, 8), -- Inline code
            { util.conceal(row:increment(2), 0, 1), util.conceal(row:get(), 7, 8) }, -- Backslash escapes
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    it('custom highlight extend', function()
        util.setup('tests/data/custom_handler.md', {
            custom_handlers = {
                markdown = { extends = true, parse = highlight_equal },
                markdown_inline = { extends = true, parse = conceal_escape },
            },
        })

        local expected, row = {}, util.row()
        vim.list_extend(expected, {
            util.heading(row:get(), 1), -- Heading
            util.inline_code(row:increment(2), 0, 8), -- Inline code
            { util.conceal(row:increment(2), 0, 1), util.conceal(row:get(), 7, 8) }, -- Backslash escapes
            highlight_equals({ row:increment(2), row:get() }, { 5, 25 }), -- Highlight equals 1
            highlight_equals({ row:increment(), row:increment() }, { 7, 7 }), -- Highlight equals 2
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
