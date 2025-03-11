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
        table.insert(virt_text, { string.rep(' ', left), 'RenderMarkdownCode' })
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

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        marks:extend(util.code_language(row:inc(2), 0, 'rust'))
        marks:add(util.code_row(row:get(), 0))
        for _ = 1, 3 do
            marks:add(util.code_row(row:inc(), 0))
        end
        marks:add(util.code_border(row:inc(), 0, false))

        marks:add(util.bullet(row:inc(2), 0, 1))
        marks:extend(util.code_language(row:inc(2), 2, 'py'))
        marks:add(util.code_row(row:get(), 2))
        for _ = 1, 2 do
            marks:add(util.code_row(row:inc(), 2))
        end
        marks:add(util.code_border(row:inc(), 2, false))

        marks:add(util.bullet(row:inc(2), 0, 1))
        marks:extend(util.code_language(row:inc(2), 2, 'lua'))
        marks:add(util.code_row(row:get(), 2))
        for _, col in ipairs({ 2, 0, 2 }) do
            if col == 0 then
                marks:add(padding(row:inc(), 0, 2, 0, 1000))
                marks:add(util.code_row(row:get(), col))
            else
                marks:add(util.code_row(row:inc(), col))
            end
        end
        marks:add(util.code_border(row:inc(), 2, false))

        marks:add(util.bullet(row:inc(2), 0, 1))
        marks:add(util.code_border(row:inc(2), 0, true))
        marks:add(util.code_row(row:inc(), 0))
        marks:add(util.code_border(row:inc(), 0, false))

        util.assert_view(marks, {
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

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        local width_1 = 34
        marks:extend(util.code_language(row:inc(2), 0, 'rust'))
        marks:add(util.code_hide(row:get(), 0, width_1))
        marks:add(util.code_row(row:get(), 0))
        for _ = 1, 3 do
            marks:add(padding(row:inc(), 0, 0, 2, 0))
            marks:add(util.code_hide(row:get(), 0, width_1))
            marks:add(util.code_row(row:get(), 0))
        end
        marks:add(util.code_border(row:inc(), 0, false, width_1))

        local width_2 = 20
        marks:add(util.bullet(row:inc(2), 0, 1))
        marks:extend(util.code_language(row:inc(2), 2, 'py'))
        marks:add(util.code_hide(row:get(), 2, width_2))
        marks:add(util.code_row(row:get(), 2))
        for _ = 1, 2 do
            marks:add(padding(row:inc(), 2, 0, 2, 1000))
            marks:add(util.code_hide(row:get(), 2, width_2))
            marks:add(util.code_row(row:get(), 2))
        end
        marks:add(util.code_border(row:inc(), 2, false, width_2))

        local width_3 = 20
        marks:add(util.bullet(row:inc(2), 0, 1))
        marks:extend(util.code_language(row:inc(2), 2, 'lua'))
        marks:add(util.code_hide(row:get(), 2, width_3))
        marks:add(util.code_row(row:get(), 2))
        for _, col in ipairs({ 2, 0, 2 }) do
            marks:add(padding(row:inc(), col, 2 - col, 2, 1000))
            marks:add(util.code_hide(row:get(), col, width_3))
            marks:add(util.code_row(row:get(), col))
        end
        marks:add(util.code_border(row:inc(), 2, false, width_3))

        local width_4 = (2 * vim.o.tabstop) + 24
        marks:add(util.bullet(row:inc(2), 0, 1))
        marks:add(util.code_border(row:inc(2), 0, true, width_4))
        marks:add(padding(row:inc(), 0, 0, vim.o.tabstop, 0))
        marks:add(util.code_hide(row:get(), 0, width_4))
        marks:add(util.code_row(row:get(), 0))
        marks:add(util.code_border(row:inc(), 0, false, width_4))

        util.assert_view(marks, {
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
