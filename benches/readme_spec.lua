---@module 'luassert'

local util = require('benches.util')

describe('README.md', function()
    it('default', function()
        local base_marks = 441
        util.between(25, 75, util.setup('README.md'))
        util.num_marks(base_marks)

        util.between(0, 1, util.move_down(1))
        util.num_marks(base_marks + 2)

        util.between(20, 40, util.insert_mode())
        util.num_marks(base_marks + 2)
    end)
end)
