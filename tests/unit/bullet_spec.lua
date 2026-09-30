---@module 'luassert'

local ordered_icons =
    require('render-markdown.settings').bullet.default.ordered_icons

describe('bullet', function()
    describe('ordered_icons', function()
        it('preserves explicit numbers greater than one', function()
            for _, value in ipairs({ '2. ', '2) ', ' 2.\t' }) do
                assert.same(
                    '2.',
                    ordered_icons({ level = 1, index = 3, value = value })
                )
            end
            assert.same(
                '10.',
                ordered_icons({ level = 1, index = 3, value = '10. ' })
            )
        end)

        it('uses the item index for markers starting at zero or one', function()
            for _, value in ipairs({ '0. ', '1. ', '1) ' }) do
                assert.same(
                    '3.',
                    ordered_icons({ level = 1, index = 3, value = value })
                )
            end
        end)

        it(
            'uses the item index when the marker cannot be converted to a number',
            function()
                for _, value in ipairs({ '', ' ', '.', ')', 'abc' }) do
                    assert.same(
                        '3.',
                        ordered_icons({ level = 1, index = 3, value = value })
                    )
                end
            end
        )
    end)
end)
