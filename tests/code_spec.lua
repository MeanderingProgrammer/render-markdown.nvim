---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param col integer
---@param offset integer
---@param left integer
---@param priority? integer
---@return render.md.MarkInfo
local function padding(row, col, offset, left, priority)
    local virt_text = {}
    if offset > 0 then
        table.insert(virt_text, { string.rep(' ', offset), 'Normal' })
    end
    if left > 0 then
        table.insert(virt_text, { string.rep(' ', left), util.hl('Code') })
    end
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { col },
        virt_text = virt_text,
        virt_text_pos = 'inline',
        priority = priority,
    }
end

describe('code.md', function()
    it('default', function()
        util.setup('tests/data/code.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        table.insert(expected, util.code_language(row:increment(2), 0, 'rust'))
        for _ = 1, 3 do
            table.insert(expected, util.code_row(row:increment(), 0))
        end
        table.insert(expected, util.code_below(row:increment(), 0))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_language(row:increment(2), 2, 'lua'),
        })
        for _ = 1, 2 do
            table.insert(expected, util.code_row(row:increment(), 2))
        end
        table.insert(expected, util.code_below(row:increment(), 2))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_language(row:increment(2), 2, 'lua'),
        })
        for _, col in ipairs({ 2, 0, 2 }) do
            if col == 0 then
                table.insert(expected, padding(row:increment(), 0, 2, 0))
                table.insert(expected, util.code_row(row:get(), col))
            else
                table.insert(expected, util.code_row(row:increment(), col))
            end
        end
        table.insert(expected, util.code_below(row:increment(), 2))

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)

    it('block padding', function()
        util.setup('tests/data/code.md', {
            code = { width = 'block', left_pad = 2, right_pad = 2 },
        })

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        table.insert(expected, util.code_language(row:increment(2), 0, 'rust', 34))
        for _ = 1, 3 do
            vim.list_extend(expected, {
                padding(row:increment(), 0, 0, 2, 0),
                util.code_hide(row:get(), 0, 34),
                util.code_row(row:get(), 0),
            })
        end
        table.insert(expected, util.code_below(row:increment(), 0, 34))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_language(row:increment(2), 2, 'lua', 20),
        })
        for _ = 1, 2 do
            vim.list_extend(expected, {
                padding(row:increment(), 2, 0, 2),
                util.code_hide(row:get(), 2, 20),
                util.code_row(row:get(), 2),
            })
        end
        table.insert(expected, util.code_below(row:increment(), 2, 20))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_language(row:increment(2), 2, 'lua', 20),
        })
        for _, col in ipairs({ 2, 0, 2 }) do
            vim.list_extend(expected, {
                padding(row:increment(), col, 2 - col, 2),
                util.code_hide(row:get(), col, 20),
                util.code_row(row:get(), col),
            })
        end
        table.insert(expected, util.code_below(row:increment(), 2, 20))

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
