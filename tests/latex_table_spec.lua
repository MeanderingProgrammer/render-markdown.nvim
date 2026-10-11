---@module 'luassert'

local util = require('tests.util')

describe('latex in table', function()
    local lines = {
        '',
        '| $\\alpha$ | $\\sigma_x^2$ |',
        '| -------- | ------------ |',
        '| 0.05     | $\\sigma_x^2$ |',
        '| 0.10     | 1.20         |',
        '',
        '| n | variance of the measured values $\\sigma_x^2$ in total |',
        '| - | ------------------------------------------------------ |',
        '| 8 | 1.20                                                   |',
    }

    util.system.mock('utftex', {
        ['\\alpha'] = { 'α' },
        ['\\sigma_x^2'] = { ' 2', 'σₓ' },
        -- single line output, like latex2text
        ['\\sigma_y'] = { 'σ_y' },
    })

    it('center', function()
        util.setup.text(lines, {
            latex = { converter = 'utftex' },
        })
        util.assert_screen({
            '┌──────────┬──────────────┐',
            '│          │  2           │',
            '│ α        │ σₓ           │',
            '├──────────┼──────────────┤',
            '│          │  2           │',
            '│ 0.05     │ σₓ           │',
            '│ 0.10     │ 1.20         │',
            '└──────────┴──────────────┘',
            '┌───┬────────────────────────────────────────────────────────┐',
            '│   │                                  2                     │',
            '│ n │ variance of the measured values σₓ in total            │',
            '├───┼────────────────────────────────────────────────────────┤',
            '│ 8 │ 1.20                                                   │',
            '└───┴────────────────────────────────────────────────────────┘',
        })
    end)

    it('below', function()
        util.setup.text(lines, {
            latex = { converter = 'utftex', position = 'below' },
        })
        util.assert_screen({
            '┌──────────┬──────────────┐',
            '│ $\\alpha$ │ $\\sigma_x^2$ │',
            '│ α        │  2           │',
            '│          │ σₓ           │',
            '├──────────┼──────────────┤',
            '│ 0.05     │ $\\sigma_x^2$ │',
            '│          │  2           │',
            '│          │ σₓ           │',
            '│ 0.10     │ 1.20         │',
            '└──────────┴──────────────┘',
            '┌───┬────────────────────────────────────────────────────────┐',
            '│ n │ variance of the measured values $\\sigma_x^2$ in total  │',
            '│   │                                  2                     │',
            '│   │                                 σₓ                     │',
            '├───┼────────────────────────────────────────────────────────┤',
            '│ 8 │ 1.20                                                   │',
            '└───┴────────────────────────────────────────────────────────┘',
        })
    end)

    it('single line above', function()
        -- any converter adds lines when not centered, cell padding comes
        -- from concealed markdown as well
        util.setup.text({
            '',
            '| **bold** | $\\sigma_y$ |',
            '| -------- | ---------- |',
            '| 0.05     | 1.20       |',
        }, {
            latex = { converter = 'utftex', position = 'above' },
        })
        util.assert_screen({
            '┌──────────┬────────────┐',
            '│          │ σ_y        │',
            '│ bold     │ $\\sigma_y$ │',
            '├──────────┼────────────┤',
            '│ 0.05     │ 1.20       │',
            '└──────────┴────────────┘',
        })
    end)

    it('wrapped', function()
        vim.o.columns = 26
        vim.o.wrap = true
        util.setup.text(lines, {
            latex = { converter = 'utftex' },
        })
        util.assert_screen({
            '┌──────────┬─────────────┐',
            '│          │  2          │',
            '│ α        │ σₓ          │',
            '├──────────┼─────────────┤',
            '│          │  2          │',
            '│ 0.05     │ σₓ          │',
            '│ 0.10     │ 1.20        │',
            '└──────────┴─────────────┘',
            '┌───┬────────────────────┐',
            '│ n │ variance of the    │',
            '│   │                  2 │',
            '│   │ measured values σₓ │',
            '│   │ in total           │',
            '├───┼────────────────────┤',
            '│ 8 │ 1.20               │',
            '└───┴────────────────────┘',
        })
        vim.o.columns = 80
        vim.o.wrap = false
    end)
end)
