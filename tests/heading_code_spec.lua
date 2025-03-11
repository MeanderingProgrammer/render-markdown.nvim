---@module 'luassert'

local util = require('tests.util')

describe('heading_code.md', function()
    it('default', function()
        util.setup('demo/heading_code.md')

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))
        marks:extend(util.heading(row:inc(2), 3))
        marks:extend(util.heading(row:inc(2), 4))
        marks:extend(util.heading(row:inc(2), 5))
        marks:extend(util.heading(row:inc(2), 6))

        marks:add(util.link(row:inc(2), { 0, 21 }, 'image'))

        marks:extend(util.code_language(row:inc(2), 0, 'python'))
        marks:add(util.code_row(row:get(), 0))
        for _ = 13, 21 do
            marks:add(util.code_row(row:inc(), 0))
        end
        marks:add(util.code_border(row:inc(), 0, false))

        util.assert_view(marks, {
            '󰫎   1 󰲡 Heading 1',
            '    2',
            '󰫎   3   󰲥 Heading 3',
            '    4',
            '󰫎   5    󰲧 Heading 4',
            '    6',
            '󰫎   7     󰲩 Heading 5',
            '    8',
            '󰫎   9      󰲫 Heading 6',
            '   10',
            '   11 󰥶 Image',
            '   12',
            '󰌠  13 󰌠 python {filename="demo.py"}',
            '   14 def main() -> None:',
            '   15     sum = 0',
            '   16     for i in range(10):',
            '   17         sum += i',
            '   18     print(sum)',
            '   19',
            '   20',
            '   21 if __name__ == "__main__":',
            '   22     main()',
            '   23 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
        })
    end)
end)
