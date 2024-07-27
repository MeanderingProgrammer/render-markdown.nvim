local async_tests = require('plenary.async.tests')
local util = require('tests.util')

async_tests.describe('ft_override.md', function()
    async_tests.it('default', function()
        util.setup('tests/data/ft_override.md')

        local actual = util.get_actual_marks()
        util.marks_are_equal({}, actual)
    end)
end)
