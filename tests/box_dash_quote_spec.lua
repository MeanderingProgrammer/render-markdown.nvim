local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('box_dash_quote.md', function()
    async_tests.it('default', function()
        util.setup('demo/box_dash_quote.md')

        local expected = {}

        -- Heading
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
                virt_text = { { ' 󰱒 ', '@markup.heading' } },
                virt_text_pos = 'overlay',
            },
            -- Custom todo, conceal list marker
            {
                row = { 4, 4 },
                col = { 0, 2 },
                conceal = '',
            },
            -- Custom todo, checkbox
            {
                row = { 4, 4 },
                col = { 2, 5 },
                virt_text = { { ' 󰥔 ', '@markup.raw' } },
                virt_text_pos = 'inline',
                conceal = '',
            },
        })

        -- Line break
        vim.list_extend(expected, {
            {
                row = { 6 },
                col = { 0 },
                virt_text = { { string.rep('─', vim.opt.columns:get()), 'LineNr' } },
                virt_text_pos = 'overlay',
            },
        })

        -- Quote lines
        vim.list_extend(expected, {
            {
                row = { 8, 8 },
                col = { 0, 4 },
                virt_text = { { '  ▋ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
            {
                row = { 9, 9 },
                col = { 0, 4 },
                virt_text = { { '  ▋ ', '@markup.quote' } },
                virt_text_pos = 'overlay',
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
