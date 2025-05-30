---@module 'luassert'

local util = require('benches.util')

describe('medium.md', function()
    it('default', function()
        local base_marks = 85
        util.less_than(util.setup('temp/medium.md'), 20)
        util.num_marks(base_marks)

        util.less_than(util.move_down(3), 0.5)
        util.num_marks(base_marks + 2)

        util.less_than(util.modify(), 2.5)
        util.num_marks(base_marks + 2)
    end)
end)
