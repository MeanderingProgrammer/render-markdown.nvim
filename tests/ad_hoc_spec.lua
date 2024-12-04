---@module 'luassert'

local util = require('tests.util')

---@param start_row integer
---@param end_row integer
---@param level integer
---@return render.md.MarkInfo[]
local function setext_heading(start_row, end_row, level)
    local sign_mark, icon_mark, background_mark = unpack(util.heading(start_row, level))
    local icon, highlight = unpack(icon_mark.virt_text[1])

    local result = {}
    for row = start_row, end_row do
        local row_background_mark = vim.deepcopy(background_mark)
        row_background_mark.row = { row, row + 1 }
        vim.list_extend(result, {
            {
                row = { row, row },
                col = { 0, 0 },
                virt_text = { { row == start_row and vim.trim(icon) .. ' ' or '  ', highlight } },
                virt_text_pos = 'inline',
            },
            row_background_mark,
        })
    end
    table.insert(result, 2, sign_mark)
    table.insert(result, #result, util.conceal(end_row, 0, 3))
    return result
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param text string
---@param highlight 'Link'|'WikiLink'
---@param conceal? string
---@return render.md.MarkInfo
local function link(row, start_col, end_col, text, highlight, conceal)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        virt_text = { { text, util.hl(highlight) } },
        virt_text_pos = 'inline',
        conceal = conceal,
    }
end

---@param row integer
---@param start_col integer
---@param end_col integer
---@param icon string
---@return render.md.MarkInfo[]
local function auto_link(row, start_col, end_col, icon)
    return {
        util.conceal(row, start_col, start_col + 1),
        link(row, start_col, end_col, icon, 'Link', nil),
        util.highlight(row, start_col, end_col, 'Link'),
        util.conceal(row, end_col - 1, end_col),
    }
end

describe('ad_hoc.md', function()
    it('custom', function()
        util.setup('tests/data/ad_hoc.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, setext_heading(row:increment(2), row:increment(2), 2))

        vim.list_extend(expected, { util.bullet(row:increment(2), 0, 1) })

        vim.list_extend(expected, {
            util.bullet(row:increment(), 0, 1),
            link(row:get(), 2, 15, '󱗖 Basic One', 'WikiLink', ''),
        })

        vim.list_extend(expected, {
            util.bullet(row:increment(), 0, 1),
            link(row:get(), 2, 25, '󱗖 With Alias', 'WikiLink', ''),
        })

        vim.list_extend(expected, {
            util.bullet(row:increment(), 0, 1),
            auto_link(row:get(), 2, 20, '󰀓 '),
        })

        vim.list_extend(expected, {
            util.bullet(row:increment(), 0, 1),
            auto_link(row:get(), 2, 26, '󰊤 '),
        })

        vim.list_extend(expected, {
            util.bullet(row:increment(), 0, 1),
            link(row:get(), 2, 61, '󰗃 ', 'Link', nil),
        })

        vim.list_extend(expected, {
            util.bullet(row:increment(), 0, 1),
            link(row:get(), 16, 25, '¹ ᴵⁿᶠᵒ', 'Link', ''),
            util.conceal(row:increment(2), 0, 16),
            link(row:increment(2), 0, 9, '¹ ᴵⁿᶠᵒ', 'Link', ''),
        })

        util.assert_view(expected, {
            '󰫎   1 󰲡 Heading',
            '    2',
            '󰫎   3 󰲣 Heading 2 Line 1',
            '    4   Heading 2 Line 2',
            '    5',
            '    6',
            '    7 ● Normal Shortcut',
            '    8 ● 󱗖 Basic One Then normal text',
            '    9 ● 󱗖 With Alias Something important',
            '   10 ● 󰀓 test@example.com Email',
            '   11 ● 󰊤 http://www.github.com/ Bare URL',
            '   12 ● 󰗃 Youtube Link',
            '   13 ● Footnote Link ¹ ᴵⁿᶠᵒ',
            '   14',
            '   15',
            '   16',
            '   17 ¹ ᴵⁿᶠᵒ: Some Info',
        })
    end)
end)
