---@module 'luassert'

local util = require('tests.util')

---@param lines string[]
---@return string
local function join(lines)
    return table.concat(lines, '\n')
end

describe('demo/latex.md', function()
    it('default', function()
        local inline = {
            raw = '\\sqrt{3x-1}+(1+x)^2',
            out = '√(3x-1)+(1+x)^2',
        }
        local block = {
            raw = {
                'f(x,y) = x + \\sqrt{y}',
                'f(x,y) = \\sqrt{y} + \\frac{x^2}{4y}',
            },
            out = {
                'f(x,y) = x + √(y)',
                'f(x,y) = √(y) + x^2/4y',
            },
        }

        util.system.mock('latex2text', {
            [inline.raw] = inline.out .. '\n',
            [join(block.raw)] = join(block.out) .. '\n',
        })
        util.setup.file('demo/latex.md')

        local marks, row = util.marks(), util.row()

        marks:add(row:get(0), 0, util.heading.sign(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

        marks:add(row:get(1, 0), { 0, 21 }, {
            virt_text = { { inline.out, 'RmMath' } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        marks:add(row:get(2), 0, {
            virt_lines = vim.iter(block.out)
                :map(function(line)
                    return { { line .. (' '):rep(24 - #line), 'RmMath' } }
                end)
                :totable(),
            virt_lines_above = true,
        })

        util.assert_view(marks, {
            '󰫎 󰲡 LaTeX',
            '',
            '  ' .. inline.out,
            '',
            '  ' .. block.out[1],
            '  ' .. block.out[2],
            '  $$',
            '  ' .. block.raw[1],
            '  ' .. block.raw[2],
            '  $$',
        })
    end)
end)
