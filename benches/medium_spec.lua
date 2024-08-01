---@module 'luassert'

local util = require('benches.util')

describe('medium.md', function()
    it('default', function()
        local base_marks = 2998
        util.between(25, 75, util.setup('temp/medium.md'))
        util.num_marks(base_marks)

        util.between(0, 1, util.move_down(3))
        util.num_marks(base_marks + 2)

        util.between(25, 50, util.insert_mode())
        util.num_marks(base_marks + 2)
    end)
end)
