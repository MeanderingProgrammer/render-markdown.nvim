---@module 'luassert'

local stub = require('luassert.stub')
local util = require('tests.util')

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

---@param row integer
---@param lines string[]
---@return render.md.test.MarkInfo
local function latex(row, lines)
    local virt_lines = vim.iter(lines)
        :map(function(line)
            return { { line, 'RmMath' } }
        end)
        :totable()
    ---@type render.md.test.MarkInfo
    return {
        row = { row },
        col = { 0 },
        virt_lines = virt_lines,
        virt_lines_above = true,
    }
end

---@param lines string[]
---@param prefix string
---@param suffix string
---@return string
local function text(lines, prefix, suffix)
    return prefix .. table.concat(lines, '\n') .. suffix
end

describe('latex.md', function()
    it('default', function()
        local inline = {
            raw = { '$\\sqrt{3x-1}+(1+x)^2$' },
            out = { '√(3x-1)+(1+x)^2' },
        }
        local block = {
            raw = {
                'f(x,y) = x + \\sqrt{y}',
                'f(x,y) = \\sqrt{y} + \\frac{x^2}{4y}',
            },
            out = {
                '    f(x,y) = x + √(y)',
                '    f(x,y) = √(y) + x^2/4y',
            },
        }

        set_responses('latex2text', {
            [text(inline.raw, '', '')] = text(inline.out, '', '\n'),
            [text(block.raw, '$$\n', '\n$$')] = text(block.out, '\n', '\n\n'),
        })
        util.setup('demo/latex.md')

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        marks:add(latex(row:inc(2), inline.out))
        marks:add(latex(row:inc(2), block.out))

        util.assert_view(marks, {
            '󰫎   1 󰲡 LaTeX',
            '    2',
            '      ' .. inline.out[1],
            '    3 ' .. inline.raw[1],
            '    4',
            '      ' .. block.out[1],
            '      ' .. block.out[2],
            '    5 $$',
            '    6 ' .. block.raw[1],
            '    7 ' .. block.raw[2],
            '    8 $$',
        })
    end)
end)
