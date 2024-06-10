local async_tests = require('plenary.async.tests')
local ui = require('render-markdown.ui')
local util = require('plenary.async.util')

local eq = assert.are.same

---@param file string
---@param opts? render.md.UserConfig
local function setup(file, opts)
    require('render-markdown').setup(opts)
    vim.cmd('e ' .. file)
    util.scheduler()
end

---@return any[]
local function get_actual_marks()
    local actual = {}
    local marks = vim.api.nvim_buf_get_extmarks(0, ui.namespace, 0, -1, { details = true })
    for _, mark in ipairs(marks) do
        local _, row, col, details = unpack(mark)
        local mark_info = {
            row = { row, details.end_row },
            col = { col, details.end_col },
            hl_eol = details.hl_eol,
            hl_group = details.hl_group,
            conceal = details.conceal,
            virt_text = details.virt_text,
            virt_text_pos = details.virt_text_pos,
            virt_lines = details.virt_lines,
            virt_lines_above = details.virt_lines_above,
        }
        table.insert(actual, mark_info)
    end
    return actual
end

---@param expected any[]
---@param actual any[]
local function marks_are_equal(expected, actual)
    eq(#expected, #actual)
    for i, expected_mark_info in ipairs(expected) do
        eq(expected_mark_info, actual[i], string.format('Marks at index %d mismatch', i))
    end
end

async_tests.describe('init', function()
    async_tests.it('render heading_code.md', function()
        setup('demo/heading_code.md')

        local expected = {}

        -- Headings 1 through 6 (minus 2)
        vim.list_extend(expected, {
            {
                row = { 0, 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 2, 3 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffDelete',
                virt_text = { { '  󰲥 ', { 'markdownH3', 'DiffDelete' } } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 4, 5 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffDelete',
                virt_text = { { '   󰲧 ', { 'markdownH4', 'DiffDelete' } } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 6, 7 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffDelete',
                virt_text = { { '    󰲩 ', { 'markdownH5', 'DiffDelete' } } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 8, 9 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffDelete',
                virt_text = { { '     󰲫 ', { 'markdownH6', 'DiffDelete' } } },
                virt_text_pos = 'overlay',
            },
        })

        -- Code block
        vim.list_extend(expected, {
            {
                row = { 10, 21 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'ColorColumn',
            },
        })

        local actual = get_actual_marks()
        marks_are_equal(expected, actual)
    end)

    async_tests.it('render list_table.md', function()
        setup('demo/list_table.md')

        local expected = {}

        -- Unordered list heading
        vim.list_extend(expected, {
            {
                row = { 0, 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        -- Unordered list
        vim.list_extend(expected, {
            -- List Item 1, bullet point
            {
                row = { 2, 2 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 2, bullet point
            {
                row = { 3, 3 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 2, inline code
            {
                row = { 3, 3 },
                col = { 20, 28 },
                hl_eol = false,
                hl_group = 'ColorColumn',
            },
            -- Nested List 1 Item 1, bullet point
            {
                row = { 4, 4 },
                col = { 2, 6 },
                virt_text = { { '  ○', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 1 Item 2, bullet point
            {
                row = { 5, 5 },
                col = { 4, 6 },
                virt_text = { { '○', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 2 Item 1, bullet point
            {
                row = { 6, 6 },
                col = { 6, 8 },
                virt_text = { { '◆', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 3 Item 1, bullet point
            {
                row = { 7, 7 },
                col = { 8, 10 },
                virt_text = { { '◇', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Nested List 4 Item 1, bullet point
            {
                row = { 8, 8 },
                col = { 10, 12 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- List Item 3, bullet point
            {
                row = { 9, 9 },
                col = { 0, 2 },
                virt_text = { { '●', 'Normal' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Ordered list heading
        vim.list_extend(expected, {
            {
                row = { 11, 12 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        -- Table heading
        vim.list_extend(expected, {
            {
                row = { 17, 18 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        local markdown_table = {
            '┌──────────────┬──────────────┐',
            '│ Heading 1    │ Heading 2    │',
            '├──────────────┼──────────────┤',
            '│ Row 1 Item 1 │ Row 1 Item 2 │',
            '│ Row 2 Item 1 │ Row 2 Item 2 │',
            '│ Row 3 Item 1 │ Row 3 Item 2 │',
            '└──────────────┴──────────────┘',
        }
        vim.list_extend(expected, {
            -- Above
            {
                row = { 19 },
                col = { 0 },
                virt_lines = { { { markdown_table[1], '@markup.heading' } } },
                virt_lines_above = true,
            },
            -- Heading
            {
                row = { 19, 19 },
                col = { 0, 31 },
                virt_text = { { markdown_table[2], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Below heading
            {
                row = { 20, 20 },
                col = { 0, 31 },
                virt_text = { { markdown_table[3], '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Rows
            {
                row = { 21, 21 },
                col = { 0, 31 },
                virt_text = { { markdown_table[4], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 22, 22 },
                col = { 0, 31 },
                virt_text = { { markdown_table[5], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 23, 23 },
                col = { 0, 31 },
                virt_text = { { markdown_table[6], 'Normal' } },
                virt_text_pos = 'overlay',
            },
            -- Below
            {
                row = { 24 },
                col = { 0 },
                virt_lines = { { { markdown_table[7], 'Normal' } } },
                virt_lines_above = true,
            },
        })

        local actual = get_actual_marks()
        marks_are_equal(expected, actual)
    end)

    async_tests.it('render box_dash_quote.md', function()
        setup('demo/box_dash_quote.md')

        local expected = {}

        -- File heading
        vim.list_extend(expected, {
            {
                row = { 0, 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        -- Checkboxes
        vim.list_extend(expected, {
            -- Unchecked, conceal list marker
            {
                row = { 2, 2 },
                col = { 0, 2 },
                conceal = '',
            },
            -- Unchecked, checkbox
            {
                row = { 2, 2 },
                col = { 2, 5 },
                virt_text = { { ' 󰄱 ', '@markup.list.unchecked' } },
                virt_text_pos = 'overlay',
            },
            -- Checked, conceal list marker
            {
                row = { 3, 3 },
                col = { 0, 2 },
                conceal = '',
            },
            -- Checked, checkbox
            {
                row = { 3, 3 },
                col = { 2, 5 },
                virt_text = { { '  ', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Line break
        vim.list_extend(expected, {
            {
                row = { 5 },
                col = { 0 },
                virt_text = { { string.rep('—', vim.opt.columns:get()), 'LineNr' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Quote lines
        vim.list_extend(expected, {
            {
                row = { 7, 7 },
                col = { 0, 4 },
                virt_text = { { '  ┃ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 8, 8 },
                col = { 0, 4 },
                virt_text = { { '  ┃ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
        })

        local actual = get_actual_marks()
        marks_are_equal(expected, actual)
    end)

    async_tests.it('render latex.md', function()
        -- TODO: mock interaction with latex2text
        setup('demo/latex.md')

        local expected = {}

        -- File heading
        vim.list_extend(expected, {
            {
                row = { 0, 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
        })

        vim.list_extend(expected, {
            -- Inline
            {
                row = { 2, 2 },
                col = { 0, 21 },
                virt_lines = { { { '√(3x-1)+(1+x)^2', '@markup.math' } } },
                virt_lines_above = true,
            },
            -- Block
            {
                row = { 4, 7 },
                col = { 0, 2 },
                virt_lines = {
                    { { 'f(x,y) = x + √(y)', '@markup.math' } },
                    { { 'f(x,y) = √(y) + x^2/4y', '@markup.math' } },
                },
                virt_lines_above = true,
            },
        })

        local actual = get_actual_marks()
        marks_are_equal(expected, actual)
    end)

    async_tests.it('render callout.md', function()
        setup('demo/callout.md')

        local expected = {}

        -- Note
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 0, 1 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 2, 2 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 2, 2 },
                col = { 2, 9 },
                virt_text = { { '󰋽 Note', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 3, 3 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticInfo' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Tip
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 5, 6 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 7, 7 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 7, 7 },
                col = { 2, 8 },
                virt_text = { { '󰌶 Tip', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 8, 8 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticOk' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Important
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 10, 11 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 12, 12 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 12, 12 },
                col = { 2, 14 },
                virt_text = { { '󰅾 Important', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 13, 13 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticHint' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Warning
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 15, 16 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 17, 17 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 17, 17 },
                col = { 2, 12 },
                virt_text = { { '󰀪 Warning', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 18, 18 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticWarn' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Caution
        vim.list_extend(expected, {
            -- Heading
            {
                row = { 20, 21 },
                col = { 0, 0 },
                hl_eol = true,
                hl_group = 'DiffAdd',
                virt_text = { { '󰲡 ', { 'markdownH1', 'DiffAdd' } } },
                virt_text_pos = 'overlay',
            },
            -- Quote start
            {
                row = { 22, 22 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
            -- Callout text
            {
                row = { 22, 22 },
                col = { 2, 12 },
                virt_text = { { '󰳦 Caution', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
            -- Quote continued
            {
                row = { 23, 23 },
                col = { 0, 2 },
                virt_text = { { '┃ ', 'DiagnosticError' } },
                virt_text_pos = 'overlay',
            },
        })

        local actual = get_actual_marks()
        marks_are_equal(expected, actual)
    end)
end)
