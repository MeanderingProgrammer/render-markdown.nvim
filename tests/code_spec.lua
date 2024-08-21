---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param col integer
---@param win_col integer
---@return render.md.MarkInfo
local function hide_background(row, col, win_col)
    ---@type render.md.MarkInfo
    return {
        row = { row },
        col = { col },
        virt_text = { { string.rep(' ', vim.opt.columns:get() * 2), 'Normal' } },
        virt_text_pos = 'win_col',
        virt_text_win_col = win_col,
    }
end

---@param row integer
---@param col integer
---@param offset integer
---@param left integer
---@return render.md.MarkInfo
local function padding(row, col, offset, left)
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
    }
end

describe('code.md', function()
    it('default', function()
        util.setup('tests/data/code.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, {
            util.code_row(row:increment(2), 0),
            util.code_language(row:get(), 3, 7, 'rust'),
        })
        for _ = 1, 3 do
            table.insert(expected, util.code_row(row:increment(), 0))
        end
        table.insert(expected, util.code_below(row:increment(), 0))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_row(row:increment(2), 2),
            util.code_language(row:get(), 5, 8, 'lua'),
        })
        for _ = 1, 2 do
            table.insert(expected, util.code_row(row:increment(), 2))
        end
        table.insert(expected, util.code_below(row:increment(), 2))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_row(row:increment(2), 2),
            util.code_language(row:get(), 5, 8, 'lua'),
        })
        for _, col in ipairs({ 2, 0, 2 }) do
            table.insert(expected, util.code_row(row:increment(), col))
            if col == 0 then
                table.insert(expected, padding(row:get(), 0, 2, 0))
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

        vim.list_extend(expected, {
            util.code_row(row:increment(2), 0),
            hide_background(row:get(), 0, 34),
            util.code_language(row:get(), 3, 7, 'rust'),
        })
        for _ = 1, 3 do
            vim.list_extend(expected, {
                util.code_row(row:increment(), 0),
                padding(row:get(), 0, 0, 2),
                hide_background(row:get(), 0, 34),
            })
        end
        table.insert(expected, util.code_below(row:increment(), 0, 34))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_row(row:increment(2), 2),
            hide_background(row:get(), 2, 20),
            util.code_language(row:get(), 5, 8, 'lua'),
        })
        for _ = 1, 2 do
            vim.list_extend(expected, {
                util.code_row(row:increment(), 2),
                padding(row:get(), 2, 0, 2),
                hide_background(row:get(), 2, 20),
            })
        end
        table.insert(expected, util.code_below(row:increment(), 2, 20))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_row(row:increment(2), 2),
            hide_background(row:get(), 2, 20),
            util.code_language(row:get(), 5, 8, 'lua'),
        })
        for _, col in ipairs({ 2, 0, 2 }) do
            vim.list_extend(expected, {
                util.code_row(row:increment(), col),
                padding(row:get(), col, 2 - col, 2),
                hide_background(row:get(), col, 20),
            })
        end
        table.insert(expected, util.code_below(row:increment(), 2, 20))

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
