---@module 'luassert'

local View = require('render-markdown.request.view')

describe('viewport row iteration', function()
    local function rows(ranges, first, last)
        local view = setmetatable({ ranges = ranges }, View)
        local result = {}
        for row in view:rows(first, last) do
            result[#result + 1] = row
        end
        return result
    end

    it(
        'clips inclusive decoration bounds to disjoint half-open view ranges',
        function()
            assert.same(
                { 5, 6, 7, 8, 9, 20, 21, 22 },
                rows({ { 0, 10 }, { 20, 30 } }, 5, 22)
            )
        end
    )

    it('does not skip a valid row after an empty first intersection', function()
        assert.same({ 20 }, rows({ { 0, 10 }, { 20, 30 } }, 10, 20))
    end)

    it('handles absent views and reversed decoration bounds', function()
        assert.same({}, rows({}, 0, 10))
        assert.same({}, rows({ { 0, 10 } }, 5, 4))
    end)
end)
