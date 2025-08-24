---@module 'luassert'

local stub = require('luassert.stub')
local util = require('tests.util')

---@param converter string
---@param responses table<string, string>
local function set_responses(converter, responses)
    stub.new(vim.fn, 'executable', function(expr)
        assert.same(converter, expr)
        return 1
    end)
    stub.new(vim.fn, 'system', function(cmd, input)
        assert.same(converter, cmd)
        local result = responses[input]
        assert.is_true(result ~= nil, 'missing output for: ' .. input)
        return result
    end)
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
        util.setup.file('demo/latex.md')

        local marks, row = util.marks(), util.row()

        marks:add(row:get(0), 0, util.heading.sign(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

        marks:add(row:get(1, 0), { 0, 21 }, {
            virt_text = { { inline.out[1], 'RmMath' } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        marks:add(row:get(2), 0, {
            virt_lines = vim.iter(block.out)
                :map(function(line)
                    return { { line .. (' '):rep(28 - #line), 'RmMath' } }
                end)
                :totable(),
            virt_lines_above = true,
        })

        util.assert_view(marks, {
            '󰫎 󰲡 LaTeX',
            '',
            '  ' .. inline.out[1],
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
