---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param icon string
---@param highlight string
---@param custom boolean
---@return render.md.MarkInfo[]
local function checkbox(row, icon, highlight, custom)
    local virt_text_pos
    local conceal
    if custom then
        virt_text_pos = 'inline'
        conceal = ''
    else
        virt_text_pos = 'overlay'
        conceal = nil
    end
    ---@type render.md.MarkInfo
    local conceal_mark = {
        row = { row, row },
        col = { 0, 2 },
        conceal = '',
    }
    ---@type render.md.MarkInfo
    local checkbox_mark = {
        row = { row, row },
        col = { 2, 5 },
        virt_text = { { icon, util.hl(highlight) } },
        virt_text_pos = virt_text_pos,
        conceal = conceal,
    }
    return { conceal_mark, checkbox_mark }
end

describe('box_dash_quote.md', function()
    it('default', function()
        util.setup('demo/box_dash_quote.md')

        local expected = {}

        -- Heading
        vim.list_extend(expected, util.heading(0, 1))

        -- Checkboxes
        vim.list_extend(expected, checkbox(2, ' 󰄱 ', 'Unchecked', false))
        vim.list_extend(expected, checkbox(3, ' 󰱒 ', 'Checked', false))
        vim.list_extend(expected, checkbox(4, ' 󰥔 ', 'Todo', true))

        -- Line break
        vim.list_extend(expected, {
            {
                row = { 6 },
                col = { 0 },
                virt_text = { { string.rep('─', vim.opt.columns:get()), util.hl('Dash') } },
                virt_text_pos = 'overlay',
            },
        })

        -- Quote lines
        vim.list_extend(expected, {
            util.quote(8, '  %s ', 'Quote'),
            util.quote(9, '  %s ', 'Quote'),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
