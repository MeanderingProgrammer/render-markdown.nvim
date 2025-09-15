---@module 'luassert'

local interval = require('render-markdown.lib.interval')

---@class render.md.test.range.Entry
---@field [1] any
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

    it('overlap inclusive', function()
        ---@type render.md.Range
        local range = { 5, 9 }
        ---@type render.md.test.range.Entry[]
        local entries = {
            { { 5, 9 }, { 5, 9 }, 'identity' },
            { { 6, 8 }, { 6, 8 }, 'inside' },
            { { 5, 9 }, { 4, 10 }, 'around' },
            { nil, { 3, 4 }, 'before' },
            { nil, { 10, 11 }, 'after' },
            { { 5, 9 }, { 4, 9 }, 'start -1' },
            { { 5, 8 }, { 4, 8 }, 'start & end -1' },
            { { 5, 9 }, { 5, 10 }, 'end +1' },
            { { 6, 9 }, { 6, 10 }, 'start & end +1' },
            { { 5, 5 }, { 4, 5 }, 'end @ start' },
            { { 9, 9 }, { 9, 10 }, 'start @ end' },
            { { 5, 6 }, { 5, 6 }, 'end @ start +1' },
            { { 8, 9 }, { 8, 9 }, 'start @ end -1' },
        }
        for _, entry in ipairs(entries) do
            local v1 = interval.overlap(range, entry[2])
            assert.same(entry[1], v1, entry[3])
            local v2 = interval.overlap(entry[2], range)
            assert.same(entry[1], v2, entry[3])
        end
    end)

    it('overlap exclusive', function()
        ---@type render.md.Range
        local range = { 5, 9 }
        ---@type render.md.test.range.Entry[]
        local entries = {
            { { 5, 9 }, { 5, 9 }, 'identity' },
            { { 6, 8 }, { 6, 8 }, 'inside' },
            { { 5, 9 }, { 4, 10 }, 'around' },
            { nil, { 3, 4 }, 'before' },
            { nil, { 10, 11 }, 'after' },
            { { 5, 9 }, { 4, 9 }, 'start -1' },
            { { 5, 8 }, { 4, 8 }, 'start & end -1' },
            { { 5, 9 }, { 5, 10 }, 'end +1' },
            { { 6, 9 }, { 6, 10 }, 'start & end +1' },
            { nil, { 4, 5 }, 'end @ start' },
            { nil, { 9, 10 }, 'start @ end' },
            { { 5, 6 }, { 5, 6 }, 'end @ start +1' },
            { { 8, 9 }, { 8, 9 }, 'start @ end -1' },
        }
        for _, entry in ipairs(entries) do
            local v1 = interval.overlap(range, entry[2], true)
            assert.same(entry[1], v1, entry[3])
            local v2 = interval.overlap(entry[2], range, true)
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
