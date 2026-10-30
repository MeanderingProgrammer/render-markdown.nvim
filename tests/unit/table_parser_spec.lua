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

    it('fit returns desired widths when they are within budget', function()
        local desired = { 8, 20, 60 }
        assert.same(desired, Parser.fit(desired, { 4, 4, 4 }, 88))
        assert.same(desired, Parser.fit(desired, { 4, 4, 4 }, 100))
    end)

    it('fit splits space based on how much columns want', function()
        -- 10 is locked leaving 86, 8 is reserved for minimums leaving 78
        -- 78 * 76 / 372 = 15.9 and 78 * 296 / 372 = 62.1 with 1 left over
        assert.same(
            { 10, 20, 66 },
            Parser.fit({ 10, 80, 300 }, { 4, 4, 4 }, 96)
        )
        -- cascades when locking a column raises the share
        assert.same({ 8, 20, 20 }, Parser.fit({ 8, 20, 60 }, { 4, 4, 4 }, 48))
    end)

    it('fit stays within minimum and uses the entire budget', function()
        local desired = { 40, 90, 300, 7 }
        local minimum = { 12, 30, 5, 3 }
        for budget = 50, 436 do
            local widths = assert(Parser.fit(desired, minimum, budget))
            local total = 0
            for i, width in ipairs(widths) do
                assert.is_true(width >= minimum[i])
                assert.is_true(width <= desired[i])
                total = total + width
            end
            assert.same(budget, total)
        end
    end)

    it('fit drops locks that would starve other minimums', function()
        -- 10 is locked leaving 95 which is below the combined minimum of 100
        assert.same(
            { 4, 51, 50 },
            Parser.fit({ 10, 100, 100 }, { 3, 50, 50 }, 105)
        )
    end)

    it('fit handles desired widths below the minimum', function()
        assert.same({ 2, 4, 4 }, Parser.fit({ 2, 10, 10 }, { 3, 3, 3 }, 10))
        assert.same({ 2, 3, 3 }, Parser.fit({ 2, 10, 10 }, { 3, 3, 3 }, 8))
    end)

    it('fit returns nothing when minimums are over budget', function()
        assert.same(nil, Parser.fit({ 8, 20, 60 }, { 4, 4, 4 }, 11))
    end)

    it('finds the longest word', function()
        local function longest(text)
            return Parser.longest_word(Parser.units({ { text, 'String' } }))
        end
        assert.same(0, longest(''))
        assert.same(0, longest('   '))
        assert.same(5, longest('ab  cdefg hi'))
        assert.same(6, longest('行行行 a'))
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
