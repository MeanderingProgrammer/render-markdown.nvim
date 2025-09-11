---@module 'luassert'

local util = require('tests.util')

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

local tab = vim.o.tabstop

local width = { 30, 16, 16, 22 + tab }

---@return render.md.test.Marks
local function shared()
    local marks, row = util.marks(), util.row()

    marks:add(row:get(0), 0, util.code.sign('rust'))
    marks:add(row:get(0, 0), { 0, 3 }, util.conceal())
    marks:add(row:get(0, 0), { 3, 7 }, util.conceal())
    marks:add(row:get(1, 1), { 0, 0 }, util.code.bg())
    marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
    marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
    marks:add(row:get(0, 0), { 0, 3 }, util.conceal())

    marks:add(row:get(2, 0), { 0, 2 }, util.bullet(1))

    marks:add(row:get(2), 2, util.code.sign('py'))
    marks:add(row:get(0, 0), { 2, 5 }, util.conceal())
    marks:add(row:get(0, 0), { 5, 7 }, util.conceal())
    marks:add(row:get(1, 1), { 2, 0 }, util.code.bg())
    marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
    marks:add(row:get(0, 1), { 2, 0 }, util.code.bg())
    marks:add(row:get(0, 0), { 2, 5 }, util.conceal())

    marks:add(row:get(4), 0, util.code.sign('lua'))
    marks:add(row:get(0, 0), { 0, 5 }, util.conceal())
    marks:add(row:get(0, 0), { 5, 8 }, util.conceal())
    marks:add(row:get(1, 1), { 0, 0 }, util.code.bg())
    marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
    marks:add(row:get(0, 1), { 0, 0 }, util.code.bg())
    marks:add(row:get(0, 0), { 0, 5 }, util.conceal())

    marks:add(row:get(2, 0), { 0, 2 }, util.bullet(1))

    marks:add(row:get(2, 0), { 0, 3 }, util.conceal())
    marks:add(row:get(1, 1), { 0, 0 }, util.code.bg())
    marks:add(row:get(0, 0), { 0, 3 }, util.conceal())

    return marks
end

describe('code', function()
    it('default', function()
        util.setup.text(lines)

        local marks, row = shared(), util.row()

        local b1 = width[1] - (2 + 4) -- icon + 'rust'
        marks:add(row:get(0), 0, util.code.border('█', true, 'rust', b1))
        marks:add(row:get(4, 0), { 0, 3 }, util.conceal_lines())

        local b2 = width[2] - (2 + 2 + 2) -- col + icon + 'py'
        marks:add(row:get(4), 2, util.code.border('█', true, 'py', b2))
        marks:add(row:get(2), 0, util.padding(2))
        marks:add(row:get(2, 0), { 2, 5 }, util.conceal_lines())

        local b3 = width[3] - (2 + 2 + 3) -- indent + icon + 'lua'
        marks:add(row:get(4), 0, util.code.border('█', true, 2, 'lua', b3))
        marks:add(row:get(4, 0), { 0, 5 }, util.conceal_lines())

        marks:add(row:get(4, 0), { 0, 3 }, util.conceal_lines())
        marks:add(row:get(2, 0), { 0, 3 }, util.conceal_lines())

        util.assert_view(marks, {
            '󱘗 󱘗 rust████████████████████████████████████████████████████████████████████████',
            '  fn main() {',
            '      println!("Hello, World!");',
            '  }',
            '',
            '  ● List Divider',
            '',
            '󰌠   󰌠 py████████████████████████████████████████████████████████████████████████',
            '    print("hello")',
            '',
            '    print("world")',
            '',
            '  Paragraph Divider',
            '',
            '󰢱 ██󰢱 lua███████████████████████████████████████████████████████████████████████',
            "    print('hello')",
            '',
            "    print('world')",
            '',
            '  ● List Divider',
            '',
            "      print('Hello, World!')",
        })
    end)

    it('block padding thin', function()
        util.setup.text(lines, {
            code = {
                width = 'block',
                left_pad = 2,
                right_pad = 2,
                border = 'thin',
                language_border = '▄',
            },
        })

        local marks, row = shared(), util.row()

        local w1 = width[1] + 4 -- left + right padding
        local b1 = w1 - (2 + 4) -- icon + 'rust'
        marks:add(row:get(0), 0, util.code.border('▄', false, 'rust', b1))
        marks:add(row:get(1), 0, util.code.padding('block', 2))
        marks:add(row:get(0), 0, util.code.hide(w1))
        marks:add(row:get(1), 0, util.code.padding('block', 2))
        marks:add(row:get(0), 0, util.code.hide(w1))
        marks:add(row:get(1), 0, util.code.padding('block', 2))
        marks:add(row:get(0), 0, util.code.hide(w1))
        marks:add(row:get(1), 0, util.code.border('▀', false, w1))

        local w2 = width[2] + 4 -- left + right padding
        local b2 = w2 - (2 + 2 + 2) -- col + icon + 'py'
        marks:add(row:get(4), 2, util.code.border('▄', false, 'py', b2))
        marks:add(row:get(1), 2, util.code.padding('block', 2))
        marks:add(row:get(0), 2, util.code.hide(w2))
        marks:add(row:get(1), 0, {
            priority = 100,
            virt_text = { { '  ', 'Normal' }, { '  ', 'RmCode' } },
            virt_text_pos = 'inline',
        })
        marks:add(row:get(0), 0, util.code.hide(w2))
        marks:add(row:get(1), 2, util.code.padding('block', 2))
        marks:add(row:get(0), 2, util.code.hide(w2))
        marks:add(row:get(1), 2, util.code.border('▀', false, w2 - 2))

        local w3 = width[3] + 4 -- left + right padding
        local b3 = w3 - (2 + 2 + 3) -- indent + icon + 'lua'
        marks:add(row:get(4), 0, util.code.border('▄', false, 2, 'lua', b3))
        marks:add(row:get(1), 0, util.code.padding('block', 2))
        marks:add(row:get(0), 0, util.code.hide(w3))
        marks:add(row:get(1), 0, util.code.padding('block', 2))
        marks:add(row:get(0), 0, util.code.hide(w3))
        marks:add(row:get(1), 0, util.code.padding('block', 2))
        marks:add(row:get(0), 0, util.code.hide(w3))
        marks:add(row:get(1), 0, util.code.border('▀', false, w3))

        local w4 = width[4] + (2 * tab) -- left + right padding (to nearest tab)
        marks:add(row:get(4), 0, util.code.border('▄', false, w4))
        marks:add(row:get(1), 0, util.code.padding('block', tab))
        marks:add(row:get(0), 0, util.code.hide(w4))
        marks:add(row:get(1), 0, util.code.border('▀', false, w4))

        util.assert_view(marks, {
            '󱘗 󱘗 rust▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '    fn main() {',
            '        println!("Hello, World!");',
            '    }',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  ● List Divider',
            '',
            '󰌠   󰌠 py▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '      print("hello")',
            '',
            '      print("world")',
            '    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  Paragraph Divider',
            '',
            '󰢱 ▄▄󰢱 lua▄▄▄▄▄▄▄▄▄▄▄▄▄',
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

    it('block right thin', function()
        util.setup.text(lines, {
            code = {
                width = 'block',
                position = 'right',
                border = 'thin',
                language_border = '▁',
                language_left = '█',
                language_right = '█',
                above = '▁',
                below = '▔',
            },
        })
        util.assert_screen({
            '󱘗 ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█󱘗 rust█',
            '  fn main() {',
            '      println!("Hello, World!");',
            '  }',
            '  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔',
            '',
            '  ● List Divider',
            '',
            '󰌠   ▁▁▁▁▁▁▁▁█󰌠 py█',
            '    print("hello")',
            '',
            '    print("world")',
            '    ▔▔▔▔▔▔▔▔▔▔▔▔▔▔',
            '',
            '  Paragraph Divider',
            '',
            '󰢱 ▁▁▁▁▁▁▁▁▁█󰢱 lua█',
            "    print('hello')",
            '',
            "    print('world')",
            '  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔',
            '',
            '  ● List Divider',
            '',
            '  ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁',
            "      print('Hello, World!')",
            '  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔',
        })
    end)

    it('quarto executable', function()
        util.setup.text({ '```  {{rust} info', '```' })
        util.assert_screen({
            '󱘗 {{󱘗 rust} info████████████████████████████████████████████████████████████████',
        })
    end)
end)
