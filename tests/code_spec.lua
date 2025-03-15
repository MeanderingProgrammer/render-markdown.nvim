---@module 'luassert'

local util = require('tests.util')

describe('code.md', function()
    it('default', function()
        util.setup('tests/data/code.md')

        local marks, row = util.marks(), util.row()

        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks
            :add(row:inc(), nil, 0, nil, util.code.sign('rust'))
            :add(row:get(), nil, 3, nil, util.code.icon('rust'))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.code.border(false, vim.o.columns))

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        marks
            :add(row:inc(2), nil, 2, nil, util.code.sign('py'))
            :add(row:get(), nil, 5, nil, util.code.icon('py'))
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), nil, 2, nil, util.code.border(false, vim.o.columns - 2))

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        marks
            :add(row:inc(2), nil, 2, nil, util.code.sign('lua'))
            :add(row:get(), nil, 5, nil, util.code.icon('lua'))
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.padding(2, 1000))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), nil, 2, nil, util.code.border(false, vim.o.columns - 2))

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        marks
            :add(row:inc(2), nil, 0, nil, util.code.border(true, vim.o.columns))
            :add(row:inc(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.code.border(false, vim.o.columns))

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

        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local width_1 = 34
        marks
            :add(row:inc(), nil, 0, nil, util.code.sign('rust'))
            :add(row:get(), nil, 3, nil, util.code.icon('rust'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_1))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
        for _ = 1, 3 do
            marks:add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
            marks:add(row:get(), nil, 0, nil, util.code.hide(width_1))
            marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        end
        marks:add(row:get(), nil, 0, nil, util.code.border(false, width_1))

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        local width_2 = 20
        marks
            :add(row:inc(2), nil, 2, nil, util.code.sign('py'))
            :add(row:get(), nil, 5, nil, util.code.icon('py'))
            :add(row:get(), nil, 2, nil, util.code.hide(width_2))
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
        for _ = 1, 2 do
            marks
                :add(row:get(), nil, 2, nil, util.padding(2, 1000, 'RmCode'))
                :add(row:get(), nil, 2, nil, util.code.hide(width_2))
                :add(row:get(), row:inc(), 2, 0, util.code.bg())
        end
        marks:add(row:get(), nil, 2, nil, util.code.border(false, width_2 - 2))

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        local width_3 = 20
        marks
            :add(row:inc(2), nil, 2, nil, util.code.sign('lua'))
            :add(row:get(), nil, 5, nil, util.code.icon('lua'))
            :add(row:get(), nil, 2, nil, util.code.hide(width_3))
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
        for _, col in ipairs({ 2, 0, 2 }) do
            if col == 0 then
                marks:add(row:get(), nil, col, nil, {
                    priority = 1000,
                    virt_text = { { '  ', 'Normal' }, { '  ', 'RmCode' } },
                    virt_text_pos = 'inline',
                })
            else
                marks:add(row:get(), nil, col, nil, util.padding(2, 1000, 'RmCode'))
            end
            marks:add(row:get(), nil, col, nil, util.code.hide(width_3))
            marks:add(row:get(), row:inc(), col, 0, util.code.bg())
        end
        marks:add(row:get(), nil, 2, nil, util.code.border(false, width_3 - 2))

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        local width_4 = (2 * vim.o.tabstop) + 24
        marks
            :add(row:inc(2), nil, 0, nil, util.code.border(true, width_4))
            :add(row:inc(), nil, 0, nil, util.padding(vim.o.tabstop, 0, 'RmCode'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_4))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.code.border(false, width_4))

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
