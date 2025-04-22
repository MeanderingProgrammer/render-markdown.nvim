---@module 'luassert'

local util = require('benches.util')

describe('README.md', function()
    it('default', function()
        local base_marks = 113
        util.less_than(util.setup('README.md'), 40)
        util.num_marks(base_marks)

        util.less_than(util.move_down(1), 0.5)
        util.num_marks(base_marks + 2)

        util.less_than(util.insert_mode(), 10)
        util.num_marks(base_marks + 2)
    end)
end)
