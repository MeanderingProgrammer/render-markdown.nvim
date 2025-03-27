---@module 'luassert'

local util = require('tests.util')

describe('code', function()
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

        marks
            :add(row:get(), nil, 0, nil, util.code.sign('rust'))
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
            :add(row:get(), nil, 0, nil, util.padding(2, 1000))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), nil, 2, nil, util.code.border(false, vim.o.columns - 2))

        marks
            :add(row:inc(4), nil, 0, nil, util.code.sign('lua'))
            :add(row:get(), nil, 5, nil, util.code.icon('lua', 2))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.code.border(false, vim.o.columns))

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        marks
            :add(row:inc(2), nil, 0, nil, util.code.border(true, vim.o.columns))
            :add(row:inc(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.code.border(false, vim.o.columns))

        util.assert_view(marks, {
            '󱘗 󱘗 rust',
            '  fn main() {',
            '      println!("Hello, World!");',
            '  }',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  ● List Divider',
            '',
            '󰌠   󰌠 py',
            '    print("hello")',
            '',
            '    print("world")',
            '    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  Paragraph Divider',
            '',
            '󰢱   󰢱 lua',
            "    print('hello')",
            '',
            "    print('world')",
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  ● List Divider',
            '',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            "      print('Hello, World!')",
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
        })
    end)

    it('block padding', function()
        util.setup.text(lines, {
            code = { width = 'block', left_pad = 2, right_pad = 2 },
        })

        local marks, row = util.marks(), util.row()

        local width_1 = 34
        marks
            :add(row:get(), nil, 0, nil, util.code.sign('rust'))
            :add(row:get(), nil, 3, nil, util.code.icon('rust'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_1))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_1))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_1))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_1))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.code.border(false, width_1))

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        local width_2 = 20
        marks
            :add(row:inc(2), nil, 2, nil, util.code.sign('py'))
            :add(row:get(), nil, 5, nil, util.code.icon('py'))
            :add(row:get(), nil, 2, nil, util.code.hide(width_2))
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), nil, 2, nil, util.padding(2, 1000, 'RmCode'))
            :add(row:get(), nil, 2, nil, util.code.hide(width_2))
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, {
                priority = 1000,
                virt_text = { { '  ', 'Normal' }, { '  ', 'RmCode' } },
                virt_text_pos = 'inline',
            })
            :add(row:get(), nil, 0, nil, util.code.hide(width_2))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 2, nil, util.padding(2, 1000, 'RmCode'))
            :add(row:get(), nil, 2, nil, util.code.hide(width_2))
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), nil, 2, nil, util.code.border(false, width_2 - 2))

        local width_3 = 20
        marks
            :add(row:inc(4), nil, 0, nil, util.code.sign('lua'))
            :add(row:get(), nil, 5, nil, util.code.icon('lua', 2))
            :add(row:get(), nil, 0, nil, util.code.hide(width_3))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_3))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_3))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_3))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.code.border(false, width_3))

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        local width_4 = (2 * vim.o.tabstop) + 24
        marks
            :add(row:inc(2), nil, 0, nil, util.code.border(true, width_4))
            :add(row:inc(), nil, 0, nil, util.padding(vim.o.tabstop, 0, 'RmCode'))
            :add(row:get(), nil, 0, nil, util.code.hide(width_4))
            :add(row:get(), row:inc(), 0, 0, util.code.bg())
            :add(row:get(), nil, 0, nil, util.code.border(false, width_4))

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
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            "          print('Hello, World!')",
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
        })
    end)
end)
