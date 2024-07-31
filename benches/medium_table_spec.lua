---@module 'luassert'

local util = require('benches.util')

describe('medium-table.md', function()
    it('default', function()
        util.between(450, 600, util.setup('temp/medium-table.md'))
        util.num_marks(30012)

        util.between(1, 5, util.move_down(1))
        util.num_marks(30014)

        util.between(400, 550, util.insert_mode())
        util.num_marks(30014)
    end)
end)
