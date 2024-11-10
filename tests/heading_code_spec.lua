---@module 'luassert'

local util = require('tests.util')

describe('heading_code.md', function()
    it('default', function()
        util.setup('demo/heading_code.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, {
            util.heading(row:get(), 1),
            util.heading(row:increment(2), 3),
            util.heading(row:increment(2), 4),
            util.heading(row:increment(2), 5),
            util.heading(row:increment(2), 6),
        })

        table.insert(expected, util.link(row:increment(2), 0, 21, 'image'))

        table.insert(expected, util.code_language(row:increment(2), 0, 'python'))
        for _ = 13, 21 do
            table.insert(expected, util.code_row(row:increment(), 0))
        end
        table.insert(expected, util.code_border(row:increment(), 0, false))

        util.assert_view(expected, {
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
