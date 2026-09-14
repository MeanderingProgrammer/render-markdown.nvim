---@module 'luassert'

local util = require('benches.util')

describe('README.md', function()
    it('default', function()
        local base_marks = 115
        util.less_than(util.setup('README.md'), 55)
        util.num_marks(base_marks)

        util.less_than(util.move_down(1), 1)
        util.num_marks(base_marks + 2)

        util.less_than(util.modify(), 15)
        util.num_marks(base_marks + 2)
    end)
end)
