---@module 'luassert'

local util = require('tests.util')

describe('code', function()
    local tab = vim.o.tabstop

    local width = { 30, 16, 16, 22 + tab }

    local lines = {
        '```rust',
        'fn main() {',
        '    println!("Hello, World!");',
        '}',
        '```',
        '',
        '- List Divider',
        '',
        '  ```py',
        '  print("hello")',
        '',
        '  print("world")',
        '  ```',
        '',
        'Paragraph Divider',
        '',
        '  ```lua',
        "  print('hello')",
        '',
        "  print('world')",
        '  ```',
        '',
        '- List Divider',
        '',
        '```',
        "	print('Hello, World!')",
        '```',
    }

    it('default', function()
        util.setup.text(lines)

        local marks, row = util.marks(), util.row()

        marks:add(row:get(0), 0, util.code.sign('rust'))
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal())
        marks:add(row:get(0), 3, util.code.icon('rust'))
        marks:add(row:get(0, 0), { 3, 7 }, util.conceal())
        marks:add(row:get(0, 1), { 0, 0 }, util.code.border('above'))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal())
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal_lines())

        marks:add(row:get(2, 0), { 0, 2 }, util.bullet(1))

        marks:add(row:get(2), 2, util.code.sign('py'))
        marks:add(row:get(0, 0), { 2, 5 }, util.conceal())
        marks:add(row:get(0), 5, util.code.icon('py'))
        marks:add(row:get(0, 0), { 5, 7 }, util.conceal())
        marks:add(row:get(0, 1), { 2, 0 }, util.code.border('above'))
        marks:add(row:get(0, 1), { 2, 0 }, util.code.bg())
        marks:add(row:get(0), 0, util.padding(2, 1000))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0, 1), { 2, 0 }, util.code.bg())
        marks:add(row:get(0, 0), { 2, 5 }, util.conceal())
        marks:add(row:get(0, 0), { 2, 5 }, util.conceal_lines())

        marks:add(row:get(4), 0, util.code.sign('lua'))
        marks:add(row:get(0, 0), { 0, 5 }, util.conceal())
        marks:add(row:get(0), 5, util.code.icon('lua', 2))
        marks:add(row:get(0, 0), { 5, 8 }, util.conceal())
        marks:add(row:get(0, 1), { 0, 0 }, util.code.border('above'))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0, 0), { 0, 5 }, util.conceal())
        marks:add(row:get(0, 0), { 0, 5 }, util.conceal_lines())

        marks:add(row:get(2, 0), { 0, 2 }, util.bullet(1))

        marks:add(row:get(2, 0), { 0, 3 }, util.conceal())
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal_lines())
        marks:add(row:get(1, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal())
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal_lines())

        util.assert_view(marks, {
            '󱘗 󱘗 rust',
            '  fn main() {',
            '      println!("Hello, World!");',
            '  }',
            '',
            '  ● List Divider',
            '',
            '󰌠   󰌠 py',
            '    print("hello")',
            '',
            '    print("world")',
            '',
            '  Paragraph Divider',
            '',
            '󰢱   󰢱 lua',
            "    print('hello')",
            '',
            "    print('world')",
            '',
            '  ● List Divider',
            '',
            "      print('Hello, World!')",
        })
    end)

    it('block thin padding', function()
        util.setup.text(lines, {
            code = {
                width = 'block',
                border = 'thin',
                left_pad = 2,
                right_pad = 2,
            },
        })

        local marks, row = util.marks(), util.row()

        local w1 = width[1] + 4
        marks:add(row:get(0), 0, util.code.sign('rust'))
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal())
        marks:add(row:get(0), 3, util.code.icon('rust'))
        marks:add(row:get(0, 0), { 3, 7 }, util.conceal())
        marks:add(row:get(0), 0, util.code.hide(w1))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.border('above'))
        marks:add(row:get(0), 0, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(0), 0, util.code.hide(w1))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0), 0, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(0), 0, util.code.hide(w1))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0), 0, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(0), 0, util.code.hide(w1))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0), 0, util.code.border('below', w1))
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal())

        marks:add(row:get(2, 0), { 0, 2 }, util.bullet(1))

        local w2 = width[2] + 4
        marks:add(row:get(2), 2, util.code.sign('py'))
        marks:add(row:get(0, 0), { 2, 5 }, util.conceal())
        marks:add(row:get(0), 5, util.code.icon('py'))
        marks:add(row:get(0, 0), { 5, 7 }, util.conceal())
        marks:add(row:get(0), 2, util.code.hide(w2))
        marks:add(row:get(0, 1), { 2, 0 }, util.code.border('above'))
        marks:add(row:get(0), 2, util.padding(2, 1000, 'RmCode'))
        marks:add(row:get(0), 2, util.code.hide(w2))
        marks:add(row:get(0, 1), { 2, 0 }, util.code.bg())
        marks:add(row:get(0), 0, {
            priority = 1000,
            virt_text = { { '  ', 'Normal' }, { '  ', 'RmCode' } },
            virt_text_pos = 'inline',
        })
        marks:add(row:get(0), 0, util.code.hide(w2))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0), 2, util.padding(2, 1000, 'RmCode'))
        marks:add(row:get(0), 2, util.code.hide(w2))
        marks:add(row:get(0, 1), { 2, 0 }, util.code.bg())
        marks:add(row:get(0), 2, util.code.border('below', w2 - 2))
        marks:add(row:get(0, 0), { 2, 5 }, util.conceal())

        local w3 = width[3] + 4
        marks:add(row:get(4), 0, util.code.sign('lua'))
        marks:add(row:get(0, 0), { 0, 5 }, util.conceal())
        marks:add(row:get(0), 5, util.code.icon('lua', 2))
        marks:add(row:get(0, 0), { 5, 8 }, util.conceal())
        marks:add(row:get(0), 0, util.code.hide(w3))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.border('above'))
        marks:add(row:get(0), 0, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(0), 0, util.code.hide(w3))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0), 0, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(0), 0, util.code.hide(w3))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0), 0, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(0), 0, util.code.hide(w3))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0), 0, util.code.border('below', w3))
        marks:add(row:get(0, 0), { 0, 5 }, util.conceal())

        marks:add(row:get(2, 0), { 0, 2 }, util.bullet(1))

        local w4 = width[4] + (2 * tab)
        marks:add(row:get(2), 0, util.code.border('above', w4))
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal())
        marks:add(row:get(1), 0, util.padding(tab, 0, 'RmCode'))
        marks:add(row:get(0), 0, util.code.hide(w4))
        marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
        marks:add(row:get(0), 0, util.code.border('below', w4))
        marks:add(row:get(0, 0), { 0, 3 }, util.conceal())

        util.assert_view(marks, {
            '󱘗 󱘗 rust',
            '    fn main() {',
            '        println!("Hello, World!");',
            '    }',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  ● List Divider',
            '',
            '󰌠   󰌠 py',
            '      print("hello")',
            '',
            '      print("world")',
            '    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  Paragraph Divider',
            '',
            '󰢱   󰢱 lua',
            "      print('hello')",
            '',
            "      print('world')",
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  ● List Divider',
            '',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            "          print('Hello, World!')",
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
        })
    end)
end)
