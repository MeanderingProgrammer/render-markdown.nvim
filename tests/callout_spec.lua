---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param start_col integer
---@param end_col integer
---@param text string
---@param highlight string
---@param conceal string?
---@return render.md.MarkInfo
local function callout(row, start_col, end_col, text, highlight, conceal)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        virt_text = { { text, util.hl(highlight) } },
        virt_text_pos = 'overlay',
        conceal = conceal,
    }
end

describe('callout.md', function()
    it('default', function()
        util.setup('demo/callout.md')

        local info = 'Info'
        local ok = 'Success'
        local hint = 'Hint'
        local warn = 'Warn'
        local error = 'Error'

        local expected = {}

        local note_start = 0
        vim.list_extend(expected, {
            util.heading(note_start, 1),
            util.quote(note_start + 2, '%s ', info),
            callout(note_start + 2, 2, 9, '󰋽 Note', info),
            util.quote(note_start + 3, '%s', info),
            util.quote(note_start + 4, '%s ', info),
            util.quote(note_start + 5, '%s', info),
            util.quote(note_start + 6, '%s ', info),
        })

        local tip_start = 8
        vim.list_extend(expected, {
            util.heading(tip_start, 1),
            util.quote(tip_start + 2, '%s ', ok),
            callout(tip_start + 2, 2, 8, '󰌶 Tip', ok),
            util.quote(tip_start + 3, '%s', ok),
            util.quote(tip_start + 4, '%s ', ok),
            util.code_row(tip_start + 4, 2),
            util.code_language(tip_start + 4, 5, 8, 'lua'),
            util.quote(tip_start + 5, '%s ', ok),
            util.code_row(tip_start + 5, 2),
            util.quote(tip_start + 6, '%s ', ok),
            util.code_below(tip_start + 6, 2),
        })

        local important_start = 16
        vim.list_extend(expected, {
            util.heading(important_start, 1),
            util.quote(important_start + 2, '%s ', hint),
            callout(important_start + 2, 2, 14, '󰅾 Important', hint),
            util.quote(important_start + 3, '%s ', hint),
        })

        local warning_start = 21
        vim.list_extend(expected, {
            util.heading(warning_start, 1),
            util.quote(warning_start + 2, '%s ', warn),
            callout(warning_start + 2, 2, 12, '󰀪 Custom Title', warn, ''),
            util.quote(warning_start + 3, '%s ', warn),
        })

        local caution_start = 26
        vim.list_extend(expected, {
            util.heading(caution_start, 1),
            util.quote(caution_start + 2, '%s ', error),
            callout(caution_start + 2, 2, 12, '󰳦 Caution', error),
            util.quote(caution_start + 3, '%s ', error),
        })

        vim.list_extend(expected, util.heading(31, 1))

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
