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
            util.code_border(row:get(), 2, false),
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

        util.assert_view(expected, {
            '󰫎   1 󰲡 Note',
            '    2',
            '    3 ▋ 󰋽 Note',
            '    4 ▋',
            '    5 ▋ A regular note',
            '    6 ▋',
            '    7 ▋ With a second paragraph',
            '    8',
            '󰫎   9 󰲡 Tip',
            '   10',
            '   11 ▋ 󰌶 Tip',
            '   12 ▋',
            '󰢱  13 ▋ 󰢱 lua',
            "   14 ▋ print('Standard tip')",
            '   15 ▋ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '   16',
            '󰫎  17 󰲡 Important',
            '   18',
            '   19 ▋ 󰅾 Important',
            '   20 ▋ Exceptional info',
            '   21',
            '󰫎  22 󰲡 Warning',
            '   23',
            '   24 ▋ 󰀪 Custom Title',
            '   25 ▋ Dastardly surprise',
            '   26',
            '󰫎  27 󰲡 Caution',
            '   28',
            '   29 ▋ 󰳦 Caution',
            '   30 ▋ Cautionary tale',
            '   31',
            '󰫎  32 󰲡 Bug',
            '   33',
            '   34 ▋ 󰨰 Bug',
            '   35 ▋ Custom bug',
        })
    end)
end)
