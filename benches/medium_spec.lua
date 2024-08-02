---@module 'luassert'

local util = require('benches.util')

describe('medium.md', function()
    it('default', function()
        local base_marks = 46
        util.between(20, 30, util.setup('temp/medium.md'))
        util.num_marks(base_marks)

        util.between(0, 5, util.move_down(3))
        util.num_marks(base_marks + 2)

        util.between(1, 15, util.insert_mode())
        util.num_marks(base_marks + 2)
    end)
end)
