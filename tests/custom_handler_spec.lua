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

    ---@param row integer
    ---@param start_col integer
    ---@param end_col integer
    ---@param conceal? string
    ---@param hl_group? string
    local function append(row, start_col, end_col, conceal, hl_group)
        table.insert(marks, {
            conceal = true,
            start_row = row,
            start_col = start_col,
            opts = { end_row = row, end_col = end_col, conceal = conceal, hl_group = hl_group },
        })
    end

    local start_row = root:range()
    local text = vim.treesitter.get_node_text(root, buf)
    for i, line in ipairs(vim.split(text, '\n', { plain = true })) do
        local row = start_row + i - 1
        ---@type integer|nil
        local position = 1
        while position ~= nil do
            local start_col, end_col = line:find('(=)=[^=]+=(=)', position)
            if start_col ~= nil and end_col ~= nil then
                -- Translate 1 based index to 0 based index, update position
                start_col, position = start_col - 1, end_col + 1
                -- Hide first 2 equal signs
                append(row, start_col, start_col + 2, '', nil)
                -- Highlight contents
                append(row, start_col, end_col, nil, 'DiffDelete')
                -- Hide last 2 equal signs
                append(row, end_col - 2, end_col, '', nil)
            else
                position = nil
            end
        end
    end
    return marks
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.MarkInfo
local function conceal(row, start_col, end_col)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        conceal = '',
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@return render.md.MarkInfo
local function highlight(row, start_col, end_col)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        hl_eol = false,
        hl_group = 'DiffDelete',
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
            { conceal(row:increment(4), 0, 1), conceal(row:get(), 7, 8) }, -- Backslash escapes
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
            { conceal(row:increment(2), 0, 1), conceal(row:get(), 7, 8) }, -- Backslash escapes
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
            { conceal(row:increment(2), 0, 1), conceal(row:get(), 7, 8) }, -- Backslash escapes
            { conceal(row:increment(2), 5, 7), highlight(row:get(), 5, 25), conceal(row:get(), 23, 25) }, -- Highlight equals
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
