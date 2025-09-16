---@module 'luassert'

local util = require('tests.util')

local inline = {
    input = '\\sqrt{3x-1}+(1+x)^2',
    output = {
        ' ┌────┐',
        '╲│3x-1 +(1+x)²',
    },
}

local block = {
    input = '\\lim_{n\\to\\infty} \\left(1 + \\frac{1}{n}\\right)^n',
    output = {
        '    ⎛    1⎞ⁿ',
        'lim ⎜1 + ─⎟',
        'n→∞ ⎝    n⎠',
    },
}

util.system.mock('utftex', {
    [inline.input] = inline.output,
    [block.input] = block.output,
})

describe('demo/latex.md', function()
    it('default', function()
        util.setup.file('demo/latex.md')

        local marks, row = util.marks(), util.row()

        marks:add(row:get(0), 0, util.heading.sign(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

        marks:add(row:get(1), 0, {
            virt_lines = {
                { { inline.output[1] .. '       ', 'RmMath' } },
            },
            virt_lines_above = true,
        })
        marks:add(row:get(0, 0), { 0, 21 }, {
            virt_text = { { inline.output[2], 'RmMath' } },
            virt_text_pos = 'inline',
            conceal = '',
        })

        marks:add(row:get(2), 0, {
            virt_lines = {
                { { block.output[1], 'RmMath' } },
                { { block.output[2] .. ' ', 'RmMath' } },
                { { block.output[3] .. ' ', 'RmMath' } },
            },
            virt_lines_above = true,
        })

        util.assert_view(marks, {
            '󰫎 󰲡 LaTeX',
            '',
            '  ' .. inline.output[1],
            '  ' .. inline.output[2],
            '',
            '  ' .. block.output[1],
            '  ' .. block.output[2],
            '  ' .. block.output[3],
            '  $$',
            '  ' .. block.input,
            '  $$',
        })
    end)
end)
