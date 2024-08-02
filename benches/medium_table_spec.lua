---@module 'luassert'

local util = require('benches.util')

describe('medium-table.md', function()
    it('default', function()
        local base_marks = 468
        util.between(80, 105, util.setup('temp/medium-table.md'))
        util.num_marks(base_marks)

        util.between(1, 20, util.move_down(1))
        util.num_marks(base_marks + 2)

        util.between(5, 30, util.insert_mode())
        util.num_marks(base_marks + 2)
    end)
end)
