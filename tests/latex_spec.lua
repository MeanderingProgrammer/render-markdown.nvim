local async_tests = require('plenary.async.tests')
local stub = require('luassert.stub')
local util = require('tests.util')

local eq = assert.are.same

async_tests.describe('latex.md', function()
    async_tests.it('default', function()
        stub.new(vim.fn, 'executable', function(expr)
            eq('latex2text', expr)
            return 1
        end)
        stub.new(vim.fn, 'system', function(cmd, input)
            eq('latex2text', cmd)
            local responses = {
                ['$\\sqrt{3x-1}+(1+x)^2$'] = '√(3x-1)+(1+x)^2\n',
                ['$$\nf(x,y) = x + \\sqrt{y}\nf(x,y) = \\sqrt{y} + \\frac{x^2}{4y}\n$$'] = '\n    f(x,y) = x + √(y)\n    f(x,y) = √(y) + x^2/4y\n\n',
            }
            return responses[input]
        end)

        util.setup('demo/latex.md')

        local expected = {}

        -- Heading
        vim.list_extend(expected, util.heading(0, 1))

        vim.list_extend(expected, {
            -- Inline
            {
                row = { 2, 2 },
                col = { 0, 21 },
                virt_lines = { { { '√(3x-1)+(1+x)^2', '@markup.math' } } },
                virt_lines_above = true,
            },
            -- Block
            {
                row = { 4, 7 },
                col = { 0, 2 },
                virt_lines = {
                    { { 'f(x,y) = x + √(y)', '@markup.math' } },
                    { { 'f(x,y) = √(y) + x^2/4y', '@markup.math' } },
                },
                virt_lines_above = true,
            },
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
