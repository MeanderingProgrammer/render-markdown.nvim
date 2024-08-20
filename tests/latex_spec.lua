---@module 'luassert'

local stub = require('luassert.stub')
local util = require('tests.util')
local eq = assert.are.same

---@param start_row integer
---@param end_row integer
---@param col integer
---@param lines string[]
---@return render.md.MarkInfo
local function latex(start_row, end_row, col, lines)
    local virt_lines = vim.iter(lines)
        :map(function(line)
            return { { line, util.hl('Math') } }
        end)
        :totable()
    ---@type render.md.MarkInfo
    return {
        row = { start_row, end_row },
        col = { 0, col },
        virt_lines = virt_lines,
        virt_lines_above = true,
    }
end

---@param converter string
---@param responses table<string, string>
local function set_responses(converter, responses)
    stub.new(vim.fn, 'executable', function(expr)
        eq(converter, expr)
        return 1
    end)
    stub.new(vim.fn, 'system', function(cmd, input)
        eq(converter, cmd)
        return responses[input]
    end)
end

describe('latex.md', function()
    it('default', function()
        set_responses('latex2text', {
            ['$\\sqrt{3x-1}+(1+x)^2$'] = '√(3x-1)+(1+x)^2\n',
            ['$$\nf(x,y) = x + \\sqrt{y}\nf(x,y) = \\sqrt{y} + \\frac{x^2}{4y}\n$$'] = '\n    f(x,y) = x + √(y)\n    f(x,y) = √(y) + x^2/4y\n\n',
        })
        util.setup('demo/latex.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, {
            latex(row:increment(2), 2, 21, { '√(3x-1)+(1+x)^2' }), -- Inline
            latex(row:increment(2), 7, 2, { '    f(x,y) = x + √(y)', '    f(x,y) = √(y) + x^2/4y' }), -- Block
        })

        local actual = util.get_actual_marks()
        util.marks_are_equal(expected, actual)
    end)
end)
