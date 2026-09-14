---@module 'luassert'

local Parser = require('render-markdown.parser.table')
local str = require('render-markdown.lib.str')

describe('table parser', function()
    it('distributes space largely evently', function()
        assert.same(
            { 8, 20, 20 },
            Parser.allocate({ 8, 20, 60 }, { 4, 4, 4 }, 48)
        )
        assert.same(
            { 4, 4, 3 },
            Parser.allocate({ 10, 10, 10 }, { 3, 3, 3 }, 11)
        )
        assert.same(
            { 4, 4, 4 },
            Parser.allocate({ 8, 20, 60 }, { 4, 4, 4 }, 12)
        )
        assert.same(
            { 8, 20, 60 },
            Parser.allocate({ 8, 20, 60 }, { 4, 4, 4 }, 100)
        )
        assert.same(nil, Parser.allocate({ 8, 20, 60 }, { 4, 4, 4 }, 11))
    end)

    it('breaks at word and token without losing highlights', function()
        local units = Parser.units({
            { 'abc def ', 'Normal' },
            { 'abcdefghij', 'String' },
        })
        assert.same({
            { { 'abc def', 'Normal' } },
            { { 'abcdefg', 'String' } },
            { { 'hij', 'String' } },
        }, Parser.wrap(units, 7))
    end)

    it('keeps composing characters and wide glyphs intact', function()
        local text = 'é行👩‍💻🇺🇸👍🏽'
        local units = Parser.units({ { text, 'String' } })
        local _, minimum = Parser.measure(units)
        local wrapped = Parser.wrap(units, minimum)
        local joined = ''
        for _, line in ipairs(wrapped) do
            assert.is_true(str.line_width(line) <= minimum)
            for _, chunk in ipairs(line) do
                joined = joined .. chunk[1]
            end
        end
        assert.same(text, joined)
        assert.same('é', units[1].text)
        assert.same('行', units[2].text)
    end)

    it('aligns each fragment including empty cells', function()
        local line = { { 'ab', 'String' } }
        assert.same(
            { { '   ', 'Normal' }, { 'ab', 'String' }, { ' ', 'Normal' } },
            Parser.align(line, 6, 'right', 1, 'Normal')
        )
        assert.same(
            { { '  ', 'Normal' }, { 'ab', 'String' }, { '  ', 'Normal' } },
            Parser.align(line, 6, 'center', 1, 'Normal')
        )
        assert.same(
            { { ' ', 'Normal' }, { '     ', 'Normal' } },
            Parser.align({}, 6, 'left', 1, 'Normal')
        )
        assert.same({ {} }, Parser.wrap({}, 1))
    end)
end)
