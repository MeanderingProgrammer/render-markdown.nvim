---@module 'luassert'

local Range = require('render-markdown.lib.range')

describe('range', function()
    it('string', function()
        assert.same('5->9', tostring(Range.new(5, 9)))
    end)

    it('contains', function()
        local range = Range.new(5, 9)
        assert.is_true(range:contains(5, 9)) -- identity
        assert.is_true(range:contains(6, 8)) -- inside
        assert.is_false(range:contains(4, 10)) -- around
        assert.is_false(range:contains(3, 4)) -- before
        assert.is_false(range:contains(10, 11)) -- after
        assert.is_false(range:contains(4, 9)) -- start -1
        assert.is_false(range:contains(4, 8)) -- start & end -1
        assert.is_false(range:contains(5, 10)) -- end +1
        assert.is_false(range:contains(6, 10)) -- start & end +1
        assert.is_false(range:contains(4, 5)) -- ends @ start
        assert.is_false(range:contains(9, 10)) -- starts @ end
    end)

    it('overlaps', function()
        local range = Range.new(5, 9)
        assert.is_true(range:overlaps(5, 9)) -- identity
        assert.is_true(range:overlaps(6, 8)) -- inside
        assert.is_true(range:overlaps(4, 10)) -- around
        assert.is_false(range:overlaps(3, 4)) -- before
        assert.is_false(range:overlaps(10, 11)) -- after
        assert.is_true(range:overlaps(4, 9)) -- start -1
        assert.is_true(range:overlaps(4, 8)) -- start & end -1
        assert.is_true(range:overlaps(5, 10)) -- end +1
        assert.is_true(range:overlaps(6, 10)) -- start & end +1
        assert.is_true(range:overlaps(4, 5)) -- ends @ start
        assert.is_true(range:overlaps(9, 10)) -- starts @ end
    end)

    it('coalesce', function()
        local ranges = {
            Range.new(3, 8),
            Range.new(13, 14),
            Range.new(12, 13),
            Range.new(25, 30),
            Range.new(14, 20),
            Range.new(1, 5),
        }
        local expected = {
            Range.new(1, 8),
            Range.new(12, 20),
            Range.new(25, 30),
        }
        assert.same(expected, Range.coalesce(ranges))
    end)
end)
