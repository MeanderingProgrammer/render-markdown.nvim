---@module 'luassert'

local util = require('tests.util')

local m22 = {
    input = '\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}',
    output = '⎛1  2⎞\n⎝3  4⎠\n',
}

local m33 = {
    input = '\\begin{pmatrix}1 & 2 & 3\\\\4 & 5 & 6\\\\7 & 8 & 9\\end{pmatrix}',
    output = '⎛1  2  3⎞\n⎜4  5  6⎟\n⎝7  8  9⎠\n',
}

util.system.mock('utftex', {
    [m22.input] = m22.output,
    [m33.input] = m33.output,
})

local lines = {
    '',
    '$' .. m22.input .. '$',
    '',
    '$' .. m22.input .. '$ & $' .. m33.input .. '$',
    '',
    '$' .. m22.input .. '$ & $$',
    m33.input,
    '$$ & $' .. m22.input .. '$',
}

describe('utftex', function()
    it('default', function()
        util.setup.text(lines, { latex = { converter = 'utftex' } })
        util.assert_screen({
            '',
            '⎛1  2⎞',
            '⎝3  4⎠',
            '',
            '⎛1  2⎞   ⎛1  2  3⎞',
            '⎝3  4⎠ & ⎜4  5  6⎟',
            '         ⎝7  8  9⎠',
            '',
            '         ⎛1  2  3⎞',
            '         ⎜4  5  6⎟',
            '⎛1  2⎞   ⎝7  8  9⎠',
            '⎝3  4⎠ & $$',
            '\\begin{pmatrix}1 & 2 & 3\\\\4 & 5 & 6\\\\7 & 8 & 9\\end{pmatrix}',
            '     ⎛1  2⎞',
            '$$ & ⎝3  4⎠',
        })
    end)

    it('above', function()
        util.setup.text(
            lines,
            { latex = { converter = 'utftex', position = 'above' } }
        )
        util.assert_screen({
            '',
            '⎛1  2⎞',
            '⎝3  4⎠',
            '$\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$',
            '',
            '                                             ⎛1  2  3⎞',
            '⎛1  2⎞                                       ⎜4  5  6⎟',
            '⎝3  4⎠                                       ⎝7  8  9⎠',
            '$\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$ & $\\begin{pmatrix}1 & 2 & 3\\\\4 & 5 &',
            '',
            '                                             ⎛1  2  3⎞',
            '⎛1  2⎞                                       ⎜4  5  6⎟',
            '⎝3  4⎠                                       ⎝7  8  9⎠',
            '$\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$ & $$',
            '\\begin{pmatrix}1 & 2 & 3\\\\4 & 5 & 6\\\\7 & 8 & 9\\end{pmatrix}',
            '     ⎛1  2⎞',
            '     ⎝3  4⎠',
            '$$ & $\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$',
        })
    end)

    it('below', function()
        util.setup.text(
            lines,
            { latex = { converter = 'utftex', position = 'below' } }
        )
        util.assert_screen({
            '',
            '$\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$',
            '⎛1  2⎞',
            '⎝3  4⎠',
            '',
            '$\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$ & $\\begin{pmatrix}1 & 2 & 3\\\\4 & 5 &',
            '⎛1  2⎞                                       ⎛1  2  3⎞',
            '⎝3  4⎠                                       ⎜4  5  6⎟',
            '                                             ⎝7  8  9⎠',
            '',
            '$\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$ & $$',
            '⎛1  2⎞',
            '⎝3  4⎠',
            '\\begin{pmatrix}1 & 2 & 3\\\\4 & 5 & 6\\\\7 & 8 & 9\\end{pmatrix}',
            '$$ & $\\begin{pmatrix}1 & 2\\\\3 & 4\\end{pmatrix}$',
            '⎛1  2  3⎞ ⎛1  2⎞',
            '⎜4  5  6⎟ ⎝3  4⎠',
            '⎝7  8  9⎠',
        })
    end)

    it('padded', function()
        util.setup.text(
            lines,
            { latex = { converter = 'utftex', top_pad = 1, bottom_pad = 1 } }
        )
        util.assert_screen({
            '',
            '',
            '⎛1  2⎞',
            '⎝3  4⎠',
            '',
            '',
            '',
            '⎛1  2⎞   ⎛1  2  3⎞',
            '⎝3  4⎠ & ⎜4  5  6⎟',
            '         ⎝7  8  9⎠',
            '',
            '',
            '',
            '         ⎛1  2  3⎞',
            '         ⎜4  5  6⎟',
            '         ⎝7  8  9⎠',
            '⎛1  2⎞',
            '⎝3  4⎠ & $$',
            '',
            '\\begin{pmatrix}1 & 2 & 3\\\\4 & 5 & 6\\\\7 & 8 & 9\\end{pmatrix}',
            '',
            '     ⎛1  2⎞',
            '$$ & ⎝3  4⎠',
            '',
        })
    end)
end)
