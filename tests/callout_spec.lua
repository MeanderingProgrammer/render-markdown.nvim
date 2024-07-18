local async_tests = require('plenary.async.tests')
local util = require('tests.util')

---@param row integer
---@param start_col integer
---@param end_col integer
---@param text string
---@param highlight string
---@return render.md.MarkInfo
local function callout(row, start_col, end_col, text, highlight)
    return {
        row = { row, row },
        col = { start_col, end_col },
        virt_text = { { text, 'RenderMarkdown' .. highlight } },
        virt_text_pos = 'overlay',
    }
end

async_tests.describe('callout.md', function()
    async_tests.it('default', function()
        util.setup('demo/callout.md')

        local info = 'Info'
        local ok = 'Success'
        local hint = 'Hint'
        local warn = 'Warn'
        local error = 'Error'

        local expected = {}

        local note_start = 0
        vim.list_extend(expected, util.heading(note_start, 1))
        vim.list_extend(expected, {
            util.quote(note_start + 2, '%s ', info), -- Quote start
            callout(note_start + 2, 2, 9, '󰋽 Note', info), -- Callout text
            util.quote(note_start + 3, '%s', info), -- Quote continued
            util.quote(note_start + 4, '%s ', info),
            util.quote(note_start + 5, '%s', info),
            util.quote(note_start + 6, '%s ', info),
        })

        local tip_start = 8
        vim.list_extend(expected, util.heading(tip_start, 1))
        vim.list_extend(expected, {
            util.quote(tip_start + 2, '%s ', ok), -- Quote start
            callout(tip_start + 2, 2, 8, '󰌶 Tip', ok), -- Callout text
            util.quote(tip_start + 3, '%s', ok), -- Quote continued
            util.quote(tip_start + 4, '%s ', ok),
            util.code_block(tip_start + 4, tip_start + 6),
        })
        vim.list_extend(expected, util.code_language(tip_start + 4, 5, 8, '󰢱 ', 'lua', 'MiniIconsAzure'))
        vim.list_extend(expected, {
            util.quote(tip_start + 5, '%s ', ok),
            util.quote(tip_start + 6, '%s ', ok),
            util.code_below(tip_start + 6, 2),
        })

        local important_start = 16
        vim.list_extend(expected, util.heading(important_start, 1))
        vim.list_extend(expected, {
            util.quote(important_start + 2, '%s ', hint), -- Quote start
            callout(important_start + 2, 2, 14, '󰅾 Important', hint), -- Callout text
            util.quote(important_start + 3, '%s ', hint), -- Quote continued
        })

        local warning_start = 21
        vim.list_extend(expected, util.heading(warning_start, 1))
        vim.list_extend(expected, {
            util.quote(warning_start + 2, '%s ', warn), -- Quote start
            callout(warning_start + 2, 2, 12, '󰀪 Warning', warn), -- Callout text
            util.quote(warning_start + 3, '%s ', warn), -- Quote continued
        })

        local caution_start = 26
        vim.list_extend(expected, util.heading(caution_start, 1))
        vim.list_extend(expected, {
            util.quote(caution_start + 2, '%s ', error), -- Quote start
            callout(caution_start + 2, 2, 12, '󰳦 Caution', error), -- Callout text
            util.quote(caution_start + 3, '%s ', error), -- Quote continued
        })

        local bug_start = 31
        vim.list_extend(expected, util.heading(bug_start, 1))
        vim.list_extend(expected, {
            util.quote(bug_start + 2, '%s ', error), -- Quote start
            callout(bug_start + 2, 2, 8, '󰨰 Bug', error), -- Callout text
            util.quote(bug_start + 3, '%s ', error), -- Quote continued
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
