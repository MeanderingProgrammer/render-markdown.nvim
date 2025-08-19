---@module 'luassert'

local interval = require('render-markdown.lib.interval')

---@class render.md.test.range.Entry
---@field [1] boolean
---@field [2] render.md.Range
---@field [3] string

describe('interval', function()
    it('contains', function()
        ---@type render.md.Range
        local range = { 5, 9 }
        ---@type render.md.test.range.Entry[]
        local entries = {
            { true, { 5, 9 }, 'identity' },
            { true, { 6, 8 }, 'inside' },
            { false, { 4, 10 }, 'around' },
            { false, { 3, 4 }, 'before' },
            { false, { 10, 11 }, 'after' },
            { false, { 4, 9 }, 'start -1' },
            { false, { 4, 8 }, 'start & end -1' },
            { false, { 5, 10 }, 'end +1' },
            { false, { 6, 10 }, 'start & end +1' },
            { false, { 4, 5 }, 'end @ start' },
            { false, { 9, 10 }, 'start @ end' },
            { true, { 5, 6 }, 'end @ start +1' },
            { true, { 8, 9 }, 'start @ end -1' },
        }
        for _, entry in ipairs(entries) do
            local actual = interval.contains(range, entry[2])
            assert.same(entry[1], actual, entry[3])
        end
    end)

    it('overlaps inclusive', function()
        ---@type render.md.Range
        local range = { 5, 9 }
        ---@type render.md.test.range.Entry[]
        local entries = {
            { true, { 5, 9 }, 'identity' },
            { true, { 6, 8 }, 'inside' },
            { true, { 4, 10 }, 'around' },
            { false, { 3, 4 }, 'before' },
            { false, { 10, 11 }, 'after' },
            { true, { 4, 9 }, 'start -1' },
            { true, { 4, 8 }, 'start & end -1' },
            { true, { 5, 10 }, 'end +1' },
            { true, { 6, 10 }, 'start & end +1' },
            { true, { 4, 5 }, 'end @ start' },
            { true, { 9, 10 }, 'start @ end' },
            { true, { 5, 6 }, 'end @ start +1' },
            { true, { 8, 9 }, 'start @ end -1' },
        }
        for _, entry in ipairs(entries) do
            local v1 = interval.overlaps(range, entry[2])
            assert.same(entry[1], v1, entry[3])
            local v2 = interval.overlaps(entry[2], range)
            assert.same(entry[1], v2, entry[3])
        end
    end)

    it('overlaps exclusive', function()
        ---@type render.md.Range
        local range = { 5, 9 }
        ---@type render.md.test.range.Entry[]
        local entries = {
            { true, { 5, 9 }, 'identity' },
            { true, { 6, 8 }, 'inside' },
            { true, { 4, 10 }, 'around' },
            { false, { 3, 4 }, 'before' },
            { false, { 10, 11 }, 'after' },
            { true, { 4, 9 }, 'start -1' },
            { true, { 4, 8 }, 'start & end -1' },
            { true, { 5, 10 }, 'end +1' },
            { true, { 6, 10 }, 'start & end +1' },
            { false, { 4, 5 }, 'end @ start' },
            { false, { 9, 10 }, 'start @ end' },
            { true, { 5, 6 }, 'end @ start +1' },
            { true, { 8, 9 }, 'start @ end -1' },
        }
        for _, entry in ipairs(entries) do
            local v1 = interval.overlaps(range, entry[2], true)
            assert.same(entry[1], v1, entry[3])
            local v2 = interval.overlaps(entry[2], range, true)
            assert.same(entry[1], v2, entry[3])
        end
    end)

    it('coalesce', function()
        ---@type render.md.Range[]
        local ranges = {
            { 3, 8 },
            { 13, 14 },
            { 12, 13 },
            { 25, 30 },
            { 14, 20 },
            { 1, 5 },
        }
        ---@type render.md.Range[]
        local expected = {
            { 1, 8 },
            { 12, 20 },
            { 25, 30 },
        }
        assert.same(expected, interval.coalesce(ranges))
    end)
end)
