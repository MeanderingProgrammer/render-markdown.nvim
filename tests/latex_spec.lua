---@module 'luassert'

local stub = require('luassert.stub')
local util = require('tests.util')

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
        assert.are.same(converter, expr)
        return 1
    end)
    stub.new(vim.fn, 'system', function(cmd, input)
        assert.are.same(converter, cmd)
        local result = responses[input]
        assert.truthy(result, 'No output for: ' .. input)
        return result
    end)
end

describe('latex.md', function()
    it('default', function()
        local in_inline = '$\\sqrt{3x-1}+(1+x)^2$'
        local out_inline = '√(3x-1)+(1+x)^2'
        local in_block = { 'f(x,y) = x + \\sqrt{y}', 'f(x,y) = \\sqrt{y} + \\frac{x^2}{4y}' }
        local out_block = { '    f(x,y) = x + √(y)', '    f(x,y) = √(y) + x^2/4y' }

        set_responses('latex2text', {
            [in_inline] = out_inline .. '\n',
            ['$$\n' .. table.concat(in_block, '\n') .. '\n$$'] = '\n' .. table.concat(out_block, '\n') .. '\n\n',
        })
        util.setup('demo/latex.md')

        local expected, row = {}, util.row()

        vim.list_extend(expected, util.heading(row:get(), 1))

        vim.list_extend(expected, {
            latex(row:increment(2), 2, 21, { out_inline }),
            latex(row:increment(2), 7, 2, out_block),
        })

        util.assert_view(expected, {
            '󰫎   1 󰲡 LaTeX',
            '    2',
            '      ' .. out_inline,
            '    3 ' .. in_inline,
            '    4',
            '      ' .. out_block[1],
            '      ' .. out_block[2],
            '    5 $$',
            '    6 ' .. in_block[1],
            '    7 ' .. in_block[2],
            '    8 $$',
        })
    end)
end)
