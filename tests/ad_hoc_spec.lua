---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param col integer
---@param link_text string
---@return render.md.MarkInfo
local function conceal_link(row, col, link_text)
    ---@type render.md.MarkInfo
    return {
        row = { row, row },
        col = { 0, col },
        virt_text = { { link_text, util.hl('Link') } },
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
            conceal_link(row:increment(4), 13, '󰌹 Basic One'),
            conceal_link(row:increment(2), 23, '󰌹 With Alias'),
            conceal_link(row:increment(2), 18, '󰀓 test@example.com'),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
