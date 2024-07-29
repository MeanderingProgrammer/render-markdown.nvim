---@module 'luassert'

local util = require('tests.util')

describe('ft_override.md', function()
    it('default', function()
        util.setup('tests/data/ft_override.md')

        local actual = util.get_actual_marks()
        util.marks_are_equal({}, actual)
    end)
end)
