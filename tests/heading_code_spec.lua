---@module 'luassert'

local util = require('tests.util')

describe('heading_code.md', function()
    it('default', function()
        util.setup.file('demo/heading_code.md')

        local marks, row = util.marks(), util.row()

        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks
            :add(row:inc(), nil, 0, nil, util.heading.sign(3))
            :add(row:get(), row:get(), 0, 3, util.heading.icon(3))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(3))

        marks
            :add(row:inc(), nil, 0, nil, util.heading.sign(4))
            :add(row:get(), row:get(), 0, 4, util.heading.icon(4))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(4))

        marks
            :add(row:inc(), nil, 0, nil, util.heading.sign(5))
            :add(row:get(), row:get(), 0, 5, util.heading.icon(5))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(5))

        marks
            :add(row:inc(), nil, 0, nil, util.heading.sign(6))
            :add(row:get(), row:get(), 0, 6, util.heading.icon(6))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(6))

        marks:add(row:inc(), nil, 0, nil, util.link('image'))

        marks
            :add(row:inc(2), nil, 0, nil, util.code.sign('python'))
            :add(row:get(), row:get(), 0, 3, util.conceal())
            :add(row:get(), nil, 3, nil, util.code.icon('python'))
            :add(row:get(), row:get(), 3, 9, util.conceal())
            :add(row:get(), row:inc(), 0, 0, util.code.border('above'))
        for _ = 14, 22 do
            marks:add(row:get(), row:inc(), 0, 0, util.code.bg())
        end
        marks:add(row:get(), row:get(), 0, 3, util.conceal())
        marks:add(row:get(), row:get(), 0, 3, util.conceal_lines())

        util.assert_view(marks, {
            '󰫎 󰲡 Heading 1',
            '',
            '󰫎   󰲥 Heading 3',
            '',
            '󰫎    󰲧 Heading 4',
            '',
            '󰫎     󰲩 Heading 5',
            '',
            '󰫎      󰲫 Heading 6',
            '',
            '  󰥶 Image',
            '',
            '󰌠 󰌠 python {filename="demo.py"}',
            '  def main() -> None:',
            '      sum = 0',
            '      for i in range(10):',
            '          sum += i',
            '      print(sum)',
            '',
            '',
            '  if __name__ == "__main__":',
            '      main()',
        })
    end)
end)
