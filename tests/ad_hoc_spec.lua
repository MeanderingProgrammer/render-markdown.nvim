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
            util.inline(row, { 0, 0 }, { row == start_row and vim.trim(icon) .. ' ' or '  ', highlight }),
            row_background_mark,
        })
    end
    table.insert(result, 2, sign_mark)
    table.insert(result, #result, util.conceal(end_row, { 0, 3 }))
    return result
end

describe('ad_hoc.md', function()
    it('custom', function()
        util.setup('tests/data/ad_hoc.md')

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        marks:extend(setext_heading(row:inc(2), row:inc(2), 2))

        marks:add(util.bullet(row:inc(2), 0, 1))

        marks:add(util.bullet(row:inc(), 0, 1))
        marks:add(util.conceal(row:get(), { 2, 3 }))
        marks:add(util.inline(row:get(), { 3, 14 }, { '󱗖 ', 'RenderMarkdownWikiLink' }))
        marks:add(util.conceal(row:get(), { 14, 15 }))

        marks:add(util.bullet(row:inc(), 0, 1))
        marks:add(util.conceal(row:get(), { 2, 3 }))
        marks:add(util.inline(row:get(), { 3, 24 }, { '󱗖 ', 'RenderMarkdownWikiLink' }))
        marks:add(util.conceal(row:get(), { 4, 13 }))
        marks:add(util.conceal(row:get(), { 24, 25 }))

        marks:add(util.bullet(row:inc(), 0, 1))
        marks:add(util.conceal(row:get(), { 2, 3 }))
        marks:add(util.inline(row:get(), { 2, 20 }, { '󰀓 ', 'RenderMarkdownLink' }))
        marks:add(util.highlight(row:get(), { 2, 20 }, 'link'))
        marks:add(util.conceal(row:get(), { 19, 20 }))

        marks:add(util.bullet(row:inc(), 0, 1))
        marks:add(util.conceal(row:get(), { 2, 3 }))
        marks:add(util.inline(row:get(), { 2, 26 }, { '󰊤 ', 'RenderMarkdownLink' }))
        marks:add(util.highlight(row:get(), { 2, 26 }, 'link'))
        marks:add(util.conceal(row:get(), { 25, 26 }))

        marks:add(util.bullet(row:inc(), 0, 1))
        marks:add(util.inline(row:get(), { 2, 61 }, { '󰗃 ', 'RenderMarkdownLink' }))

        marks:add(util.bullet(row:inc(), 0, 1))
        marks:add(util.inline(row:get(), { 16, 25 }, { '¹ ᴵⁿᶠᵒ', 'RenderMarkdownLink' }, ''))
        marks:add(util.conceal(row:inc(2), { 0, 16 }))
        marks:add(util.inline(row:inc(2), { 0, 9 }, { '¹ ᴵⁿᶠᵒ', 'RenderMarkdownLink' }, ''))

        util.assert_view(marks, {
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
