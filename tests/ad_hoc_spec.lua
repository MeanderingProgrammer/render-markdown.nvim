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
---@param length integer
---@param link_text string
---@param highlight 'Link'|'WikiLink'
---@param conceal string?
---@return render.md.MarkInfo[]
local function bullet_link(row, length, link_text, highlight, conceal)
    ---@type render.md.MarkInfo
    local link = {
        row = { row, row },
        col = { 2, 2 + length },
        virt_text = { { link_text, util.hl(highlight) } },
        virt_text_pos = 'inline',
        conceal = conceal,
    }
    return { util.bullet(row, 0, 1), link }
end

describe('ad_hoc.md', function()
    it('custom', function()
        util.setup('tests/data/ad_hoc.md', {
            link = {
                custom = {
                    youtube = { pattern = 'www%.youtube%.com/', icon = ' ', highlight = util.hl('Link') },
                },
            },
        })

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, setext_heading(row:increment(2), row:increment(2), 2))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            bullet_link(row:increment(), 13, '󱗖 Basic One', 'WikiLink', ''),
            bullet_link(row:increment(), 23, '󱗖 With Alias', 'WikiLink', ''),
            bullet_link(row:increment(), 18, '󰀓 test@example.com', 'Link', ''),
            bullet_link(row:increment(), 59, ' ', 'Link', nil),
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
            '   11 ●  Youtube Link',
        })
    end)
end)
