---@module 'luassert'

local util = require('tests.util')

---@param start_row integer
---@param end_row integer
---@param level integer
---@return render.md.MarkInfo[]
local function setext_heading(start_row, end_row, level)
    local result = util.heading(start_row, level)
    local background_mark = table.remove(result, #result)
    local icon_mark = table.remove(result, #result)

    for row = start_row, end_row do
        local row_background_mark = vim.deepcopy(background_mark)
        row_background_mark.row = { row, row + 1 }
        table.insert(result, row_background_mark)
    end

    icon_mark.row = { start_row, end_row + 1 }
    icon_mark.col = { 0, 0 }
    icon_mark.virt_text[1][1] = vim.trim(icon_mark.virt_text[1][1]) .. ' '
    icon_mark.virt_text_pos = 'inline'
    table.insert(result, 3, icon_mark)

    table.insert(result, #result, util.conceal(end_row, 0, 3))

    return result
end

---@param row integer
---@param length integer
---@param link_text string
---@param conceal string?
---@return render.md.MarkInfo[]
local function bullet_link(row, length, link_text, conceal)
    ---@type render.md.MarkInfo
    local link = {
        row = { row, row },
        col = { 2, 2 + length },
        virt_text = { { link_text, util.hl('Link') } },
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
            bullet_link(row:increment(), 13, '󰌹 Basic One', ''),
            bullet_link(row:increment(), 23, '󰌹 With Alias', ''),
            bullet_link(row:increment(), 18, '󰀓 test@example.com', ''),
            bullet_link(row:increment(), 59, ' ', nil),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
