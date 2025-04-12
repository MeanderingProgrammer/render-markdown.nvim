---@module 'luassert'

local Range = require('render-markdown.core.range')

local Eq = assert.are.same
local True = assert.True
local False = assert.False

describe('range', function()
    it('contains', function()
        local range = Range.new(5, 9)
        True(range:contains(5, 9)) -- identity
        True(range:contains(6, 8)) -- inside
        False(range:contains(4, 10)) -- around
        False(range:contains(3, 4)) -- before
        False(range:contains(10, 11)) -- after
        False(range:contains(4, 9)) -- start -1
        False(range:contains(4, 8)) -- start & end -1
        False(range:contains(5, 10)) -- end +1
        False(range:contains(6, 10)) -- start & end +1
        False(range:contains(4, 5)) -- ends @ start
        False(range:contains(9, 10)) -- starts @ end
    end)

    it('overlaps', function()
        local range = Range.new(5, 9)
        True(range:overlaps(5, 9)) -- identity
        True(range:overlaps(6, 8)) -- inside
        True(range:overlaps(4, 10)) -- around
        False(range:overlaps(3, 4)) -- before
        False(range:overlaps(10, 11)) -- after
        True(range:overlaps(4, 9)) -- start -1
        True(range:overlaps(4, 8)) -- start & end -1
        True(range:overlaps(5, 10)) -- end +1
        True(range:overlaps(6, 10)) -- start & end +1
        True(range:overlaps(4, 5)) -- ends @ start
        True(range:overlaps(9, 10)) -- starts @ end
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
        Eq(expected, Range.coalesce(ranges))
    end)
end)
