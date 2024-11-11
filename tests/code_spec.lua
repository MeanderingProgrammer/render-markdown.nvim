---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param col integer
---@param offset integer
---@param left integer
---@param priority integer
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
        table.insert(expected, util.code_border(row:increment(), 0, false))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_language(row:increment(2), 2, 'py'),
        })
        for _ = 1, 2 do
            table.insert(expected, util.code_row(row:increment(), 2))
        end
        table.insert(expected, util.code_border(row:increment(), 2, false))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_language(row:increment(2), 2, 'lua'),
        })
        for _, col in ipairs({ 2, 0, 2 }) do
            if col == 0 then
                table.insert(expected, padding(row:increment(), 0, 2, 0, 1000))
                table.insert(expected, util.code_row(row:get(), col))
            else
                table.insert(expected, util.code_row(row:increment(), col))
            end
        end
        table.insert(expected, util.code_border(row:increment(), 2, false))

        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_border(row:increment(2), 0, true),
            util.code_row(row:increment(), 0),
            util.code_border(row:increment(), 0, false),
        })

        util.assert_view(expected, {
            '󰫎   1 󰲡 Heading',
            '    2',
            '󱘗   3 󱘗 rust',
            '    4 fn main() {',
            '    5     println!("Hello, World!");',
            '    6 }',
            '    7 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '    8',
            '    9 ● Nested code',
            '   10',
            '󰌠  11   󰌠 py',
            '   12   print("hello")',
            '   13   print("world")',
            '   14   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '   15',
            '   16 ● Nested code with blank',
            '   17',
            '󰢱  18   󰢱 lua',
            "   19   print('hello')",
            '   20',
            "   21   print('world')",
            '   22   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '   23',
            '   24 ● No language',
            '   25',
            '   26 ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            "   27     print('Hello, World!')",
            '   28 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
        })
    end)

    it('block padding', function()
        util.setup('tests/data/code.md', {
            code = { width = 'block', left_pad = 2, right_pad = 2 },
        })

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        local width_1 = 34
        table.insert(expected, util.code_language(row:increment(2), 0, 'rust', width_1))
        for _ = 1, 3 do
            vim.list_extend(expected, {
                padding(row:increment(), 0, 0, 2, 0),
                util.code_hide(row:get(), 0, width_1),
                util.code_row(row:get(), 0),
            })
        end
        table.insert(expected, util.code_border(row:increment(), 0, false, width_1))

        local width_2 = 20
        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_language(row:increment(2), 2, 'py', width_2),
        })
        for _ = 1, 2 do
            vim.list_extend(expected, {
                padding(row:increment(), 2, 0, 2, 1000),
                util.code_hide(row:get(), 2, width_2),
                util.code_row(row:get(), 2),
            })
        end
        table.insert(expected, util.code_border(row:increment(), 2, false, width_2))

        local width_3 = 20
        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_language(row:increment(2), 2, 'lua', width_3),
        })
        for _, col in ipairs({ 2, 0, 2 }) do
            vim.list_extend(expected, {
                padding(row:increment(), col, 2 - col, 2, 1000),
                util.code_hide(row:get(), col, width_3),
                util.code_row(row:get(), col),
            })
        end
        table.insert(expected, util.code_border(row:increment(), 2, false, width_3))

        local width_4 = (2 * vim.o.tabstop) + 24
        vim.list_extend(expected, {
            util.bullet(row:increment(2), 0, 1),
            util.code_border(row:increment(2), 0, true, width_4),
            padding(row:increment(), 0, 0, vim.o.tabstop, 0),
            util.code_hide(row:get(), 0, width_4),
            util.code_row(row:get(), 0),
            util.code_border(row:increment(), 0, false, width_4),
        })

        util.assert_view(expected, {
            '󰫎   1 󰲡 Heading',
            '    2',
            '󱘗   3 󱘗 rust',
            '    4   fn main() {',
            '    5       println!("Hello, World!");',
            '    6   }',
            '    7 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '    8',
            '    9 ● Nested code',
            '   10',
            '󰌠  11   󰌠 py',
            '   12     print("hello")',
            '   13     print("world")',
            '   14   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '   15',
            '   16 ● Nested code with blank',
            '   17',
            '󰢱  18   󰢱 lua',
            "   19     print('hello')",
            '   20',
            "   21     print('world')",
            '   22   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '   23',
            '   24 ● No language',
            '   25',
            '   26 ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            "   27         print('Hello, World!')",
            '   28 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
        })
    end)
end)
