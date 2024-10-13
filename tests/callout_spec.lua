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

        local expected, row = {}, util.row()

        local info = 'Info'
        vim.list_extend(expected, {
            util.heading(row:get(), 1),
            util.quote(row:increment(2), '%s ', info),
            callout(row:get(), 2, 9, '󰋽 Note', info),
            util.quote(row:increment(), '%s', info),
            util.quote(row:increment(), '%s ', info),
            util.quote(row:increment(), '%s', info),
            util.quote(row:increment(), '%s ', info),
        })

        local ok = 'Success'
        vim.list_extend(expected, {
            util.heading(row:increment(2), 1),
            util.quote(row:increment(2), '%s ', ok),
            callout(row:get(), 2, 8, '󰌶 Tip', ok),
            util.quote(row:increment(), '%s', ok),
            util.quote(row:increment(), '%s ', ok),
            util.code_language(row:get(), 2, 'lua'),
            util.quote(row:increment(), '%s ', ok),
            util.code_row(row:get(), 2),
            util.quote(row:increment(), '%s ', ok),
            util.code_below(row:get(), 2),
        })

        local hint = 'Hint'
        vim.list_extend(expected, {
            util.heading(row:increment(2), 1),
            util.quote(row:increment(2), '%s ', hint),
            callout(row:get(), 2, 14, '󰅾 Important', hint),
            util.quote(row:increment(1), '%s ', hint),
        })

        local warn = 'Warn'
        vim.list_extend(expected, {
            util.heading(row:increment(2), 1),
            util.quote(row:increment(2), '%s ', warn),
            callout(row:get(), 2, 12, '󰀪 Custom Title', warn, ''),
            util.quote(row:increment(), '%s ', warn),
        })

        local error = 'Error'
        vim.list_extend(expected, {
            util.heading(row:increment(2), 1),
            util.quote(row:increment(2), '%s ', error),
            callout(row:get(), 2, 12, '󰳦 Caution', error),
            util.quote(row:increment(), '%s ', error),
        })

        vim.list_extend(expected, {
            util.heading(row:increment(2), 1),
            util.quote(row:increment(2), '%s ', error),
            callout(row:get(), 2, 8, '󰨰 Bug', error),
            util.quote(row:increment(), '%s ', error),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
