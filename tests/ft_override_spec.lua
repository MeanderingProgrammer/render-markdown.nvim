---@module 'luassert'

local util = require('tests.util')

describe('ft_override.md', function()
    it('default', function()
        util.setup('tests/data/ft_override.md')
        util.assert_marks({})
    end)
end)
