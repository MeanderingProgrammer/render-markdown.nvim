---@module 'luassert'

local util = require('benches.util')

describe('medium-table.md', function()
    it('default', function()
        local base_marks = 341
        util.less_than(util.setup('temp/medium-table.md'), 120)
        util.num_marks(base_marks)

        util.less_than(util.move_down(1), 20)
        util.num_marks(base_marks + 2)

        util.less_than(util.insert_mode(), 25)
        util.num_marks(base_marks + 2)
    end)
end)
