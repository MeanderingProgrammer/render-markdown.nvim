local async_tests = require('plenary.async.tests')
local stub = require('luassert.stub')
local util = require('tests.util')

local eq = assert.are.same

---@param start_row integer
---@param end_row integer
---@param start_col integer
---@param end_col integer
---@param lines string[]
---@return render.md.MarkInfo
local function latex(start_row, end_row, start_col, end_col, lines)
    local virt_lines = vim.tbl_map(function(line)
        return { { line, 'RenderMarkdownMath' } }
    end, lines)
    return {
        row = { start_row, end_row },
        col = { start_col, end_col },
        virt_lines = virt_lines,
        virt_lines_above = true,
    }
end

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

        vim.list_extend(expected, util.heading(0, 1))
        vim.list_extend(expected, {
            -- Inline
            latex(2, 2, 0, 21, { '√(3x-1)+(1+x)^2' }),
            -- Block
            latex(4, 7, 0, 2, { 'f(x,y) = x + √(y)', 'f(x,y) = √(y) + x^2/4y' }),
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
