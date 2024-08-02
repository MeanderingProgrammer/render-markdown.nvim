---@module 'luassert'

local util = require('benches.util')

describe('README.md', function()
    it('default', function()
        local base_marks = 55
        util.between(30, 50, util.setup('README.md'))
        util.num_marks(base_marks)

        util.between(1, 5, util.move_down(1))
        util.num_marks(base_marks + 2)

        util.between(10, 20, util.insert_mode())
        util.num_marks(base_marks + 2)
    end)
end)
