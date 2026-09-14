---@module 'luassert'

local util = require('benches.util')

describe('medium-table.md', function()
    it('default', function()
        local base_marks = 347
        util.less_than(util.setup('temp/medium-table.md'), 125)
        util.num_marks(base_marks)

        util.less_than(util.move_down(1), 1)
        util.num_marks(base_marks + 1)

        util.less_than(util.modify(), 15)
        util.num_marks(base_marks + 1)
    end)
end)
