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

        marks:add(row:get(), nil, 0, nil, util.code.sign('rust'))
        marks:add(row:get(), row:get(), 0, 3, util.conceal())
        marks:add(row:get(), nil, 3, nil, util.code.icon('rust'))
        marks:add(row:get(), row:get(), 3, 7, util.conceal())
        marks:add(row:get(), row:inc(), 0, 0, util.code.border('above'))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), row:get(), 0, 3, util.conceal())
        marks:add(row:get(), row:get(), 0, 3, util.conceal_lines())

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        marks:add(row:inc(2), nil, 2, nil, util.code.sign('py'))
        marks:add(row:get(), row:get(), 2, 5, util.conceal())
        marks:add(row:get(), nil, 5, nil, util.code.icon('py'))
        marks:add(row:get(), row:get(), 5, 7, util.conceal())
        marks:add(row:get(), row:inc(), 2, 0, util.code.border('above'))
        marks:add(row:get(), row:inc(), 2, 0, util.code.bg())
        marks:add(row:get(), nil, 0, nil, util.padding(2, 1000))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), row:inc(), 2, 0, util.code.bg())
        marks:add(row:get(), row:get(), 2, 5, util.conceal())
        marks:add(row:get(), row:get(), 2, 5, util.conceal_lines())

        marks:add(row:inc(4), nil, 0, nil, util.code.sign('lua'))
        marks:add(row:get(), row:get(), 0, 5, util.conceal())
        marks:add(row:get(), nil, 5, nil, util.code.icon('lua', 2))
        marks:add(row:get(), row:get(), 5, 8, util.conceal())
        marks:add(row:get(), row:inc(), 0, 0, util.code.border('above'))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), row:get(), 0, 5, util.conceal())
        marks:add(row:get(), row:get(), 0, 5, util.conceal_lines())

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        marks:add(row:inc(2), row:get(), 0, 3, util.conceal())
        marks:add(row:get(), row:get(), 0, 3, util.conceal_lines())
        marks:add(row:inc(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), row:get(), 0, 3, util.conceal())
        marks:add(row:get(), row:get(), 0, 3, util.conceal_lines())

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

        local width_1 = 34
        marks:add(row:get(), nil, 0, nil, util.code.sign('rust'))
        marks:add(row:get(), row:get(), 0, 3, util.conceal())
        marks:add(row:get(), nil, 3, nil, util.code.icon('rust'))
        marks:add(row:get(), row:get(), 3, 7, util.conceal())
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_1))
        marks:add(row:get(), row:inc(), 0, 0, util.code.border('above'))
        marks:add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_1))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_1))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_1))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), nil, 0, nil, util.code.border('below', width_1))
        marks:add(row:get(), row:get(), 0, 3, util.conceal())

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        local width_2 = 20
        marks:add(row:inc(2), nil, 2, nil, util.code.sign('py'))
        marks:add(row:get(), row:get(), 2, 5, util.conceal())
        marks:add(row:get(), nil, 5, nil, util.code.icon('py'))
        marks:add(row:get(), row:get(), 5, 7, util.conceal())
        marks:add(row:get(), nil, 2, nil, util.code.hide(width_2))
        marks:add(row:get(), row:inc(), 2, 0, util.code.border('above'))
        marks:add(row:get(), nil, 2, nil, util.padding(2, 1000, 'RmCode'))
        marks:add(row:get(), nil, 2, nil, util.code.hide(width_2))
        marks:add(row:get(), row:inc(), 2, 0, util.code.bg())
        marks:add(row:get(), nil, 0, nil, {
            priority = 1000,
            virt_text = { { '  ', 'Normal' }, { '  ', 'RmCode' } },
            virt_text_pos = 'inline',
        })
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_2))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), nil, 2, nil, util.padding(2, 1000, 'RmCode'))
        marks:add(row:get(), nil, 2, nil, util.code.hide(width_2))
        marks:add(row:get(), row:inc(), 2, 0, util.code.bg())
        marks:add(
            row:get(),
            nil,
            2,
            nil,
            util.code.border('below', width_2 - 2)
        )
        marks:add(row:get(), row:get(), 2, 5, util.conceal())

        local width_3 = 20
        marks:add(row:inc(4), nil, 0, nil, util.code.sign('lua'))
        marks:add(row:get(), row:get(), 0, 5, util.conceal())
        marks:add(row:get(), nil, 5, nil, util.code.icon('lua', 2))
        marks:add(row:get(), row:get(), 5, 8, util.conceal())
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_3))
        marks:add(row:get(), row:inc(), 0, 0, util.code.border('above'))
        marks:add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_3))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_3))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), nil, 0, nil, util.padding(2, 0, 'RmCode'))
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_3))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), nil, 0, nil, util.code.border('below', width_3))
        marks:add(row:get(), row:get(), 0, 5, util.conceal())

        marks:add(row:inc(2), row:get(), 0, 2, util.bullet(1))

        local tab = vim.o.tabstop
        local width_4 = (3 * tab) + 22
        marks:add(row:inc(2), nil, 0, nil, util.code.border('above', width_4))
        marks:add(row:get(), row:get(), 0, 3, util.conceal())
        marks:add(row:inc(), nil, 0, nil, util.padding(tab, 0, 'RmCode'))
        marks:add(row:get(), nil, 0, nil, util.code.hide(width_4))
        marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        marks:add(row:get(), nil, 0, nil, util.code.border('below', width_4))
        marks:add(row:get(), row:get(), 0, 3, util.conceal())

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

    describe('thin border', function()
        lines = {
            '```rust',
            '```',
            '',
            '```rust {filename="test.rs"}',
            '```',
            '',
            '```rust',
            'println!("long line beyond header width");',
            '```',
            '',
            '```rust {filename="test.rs"}',
            'println!("long line beyond header width");',
            '```',
        }

        local code = {
            sign = false,
            -- min_width = 34,
            border = 'thin',
            above = '─',
            below = '─',
            thin_border_pad = 1,
            thin_border_pad_char = ' ',
        }

        it('block left pad 0', function()
            require('mini.icons').setup({})
            local has, icons_or_err = pcall(require, 'mini.icons')
            assert(has, 'mini.icons not found: ' .. tostring(icons_or_err))

            code.width = 'block'
            code.position = 'left'
            code.language_pad = 0

            util.setup.text(lines, { code = code })

            util.assert_screen({
                '󱘗 rust',
                '──────',
                '',
                '󱘗 rust {filename="test.rs"}',
                '───────────────────────────',
                '',
                '󱘗 rust ───────────────────────────────────',
                'println!("long line beyond header width");',
                '──────────────────────────────────────────',
                '',
                '󱘗 rust {filename="test.rs"} ──────────────',
                'println!("long line beyond header width");',
                '──────────────────────────────────────────',
            })
        end)

        it('block left pad 0 no conceal', function()
            code.width = 'block'
            code.position = 'left'
            code.language_pad = 0

            util.setup.text(lines, {
                code = code,
                win_options = { conceallevel = { rendered = 0 } },
            })

            util.assert_screen({
                '```󱘗 rustrust',
                '```──────────',
                '',
                '```󱘗 rustrust {filename="test.rs"}',
                '```───────────────────────────────',
                '',
                '```󱘗 rustrust ────────────────────────────',
                'println!("long line beyond header width");',
                '```───────────────────────────────────────',
                '',
                '```󱘗 rustrust {filename="test.rs"} ───────',
                'println!("long line beyond header width");',
                '```───────────────────────────────────────',
            })
        end)

        it('block left pad 2', function()
            code.width = 'block'
            code.position = 'left'
            code.language_pad = 2

            util.setup.text(lines, { code = code })

            util.assert_screen({
                '─ 󱘗 rust',
                '────────',
                '',
                '─ 󱘗 rust {filename="test.rs"}',
                '─────────────────────────────',
                '',
                '─ 󱘗 rust ─────────────────────────────────',
                'println!("long line beyond header width");',
                '──────────────────────────────────────────',
                '',
                '─ 󱘗 rust {filename="test.rs"} ────────────',
                'println!("long line beyond header width");',
                '──────────────────────────────────────────',
            })
        end)

        it('block left pad 2 no conceal', function()
            code.width = 'block'
            code.position = 'left'
            code.language_pad = 2

            util.setup.text(lines, {
                code = code,
                win_options = { conceallevel = { rendered = 0 } },
            })

            util.assert_screen({
                '```─ 󱘗 rustrust',
                '```────────────',
                '',
                '```─ 󱘗 rustrust {filename="test.rs"}',
                '```─────────────────────────────────',
                '',
                '```─ 󱘗 rustrust ──────────────────────────',
                'println!("long line beyond header width");',
                '```───────────────────────────────────────',
                '',
                '```─ 󱘗 rustrust {filename="test.rs"} ─────',
                'println!("long line beyond header width");',
                '```───────────────────────────────────────',
            })
        end)

        it('block right pad 0', function()
            code.width = 'block'
            code.position = 'right'
            code.language_pad = 0
            util.setup.text(lines, { code = code })

            util.assert_screen({
                '󱘗 rust',
                '──────',
                '',
                ' {filename="test.rs"} 󱘗 rust',
                '────────────────────────────',
                '',
                '─────────────────────────────────── 󱘗 rust',
                'println!("long line beyond header width");',
                '──────────────────────────────────────────',
                '',
                ' {filename="test.rs"} ───────────── 󱘗 rust',
                'println!("long line beyond header width");',
                '──────────────────────────────────────────',
            })
        end)

        it('block right pad 0 no conceal', function()
            code.width = 'block'
            code.position = 'right'
            code.language_pad = 0

            util.setup.text(lines, {
                code = code,
                win_options = { conceallevel = { rendered = 0 } },
            })

            util.assert_screen({
                '```rust󱘗 rust',
                '```──────────',
                '',
                '```rust {filename="test.rs"} 󱘗 rust',
                '```────────────────────────────────',
                '',
                '```rust──────────────────────────── 󱘗 rust',
                'println!("long line beyond header width");',
                '```───────────────────────────────────────',
                '',
                '```rust {filename="test.rs"} ────── 󱘗 rust',
                'println!("long line beyond header width");',
                '```───────────────────────────────────────',
            })
        end)

        it('block right pad 2', function()
            code.width = 'block'
            code.position = 'right'
            code.language_pad = 2
            util.setup.text(lines, { code = code })

            util.assert_screen({
                '󱘗 rust ─',
                '────────',
                '',
                ' {filename="test.rs"} 󱘗 rust ─',
                '──────────────────────────────',
                '',
                '───────────────────────────────── 󱘗 rust ─',
                'println!("long line beyond header width");',
                '──────────────────────────────────────────',
                '',
                ' {filename="test.rs"} ─────────── 󱘗 rust ─',
                'println!("long line beyond header width");',
                '──────────────────────────────────────────',
            })
        end)

        it('block right pad 2 no conceal', function()
            code.width = 'block'
            code.position = 'right'
            code.language_pad = 2

            util.setup.text(lines, {
                code = code,
                win_options = { conceallevel = { rendered = 0 } },
            })

            util.assert_screen({
                '```rust󱘗 rust ─',
                '```────────────',
                '',
                '```rust {filename="test.rs"} 󱘗 rust ─',
                '```──────────────────────────────────',
                '',
                '```rust────────────────────────── 󱘗 rust ─',
                'println!("long line beyond header width");',
                '```───────────────────────────────────────',
                '',
                '```rust {filename="test.rs"} ──── 󱘗 rust ─',
                'println!("long line beyond header width");',
                '```───────────────────────────────────────',
            })
        end)
    end)
end)
