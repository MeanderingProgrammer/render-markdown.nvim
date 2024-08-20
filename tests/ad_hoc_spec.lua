---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param start_col integer
---@param end_col integer
---@param text string
---@return render.md.MarkInfo
local function wiki_link(row, start_col, end_col, text)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { start_col, end_col },
        virt_text = { { '󰌹 ' .. text, util.hl('Link') } },
        virt_text_pos = 'inline',
        conceal = '',
    }
end

describe('ad_hoc.md', function()
    it('default', function()
        util.setup('tests/data/ad_hoc.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, {
            wiki_link(row:increment(4), 0, 13, 'Basic One'),
            wiki_link(row:increment(2), 0, 23, 'With Alias'),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
