---@module 'luassert'

local util = require('benches.util')

describe('README.md', function()
    it('default', function()
        util.between(25, 75, util.setup('README.md'))
        util.num_marks(442)

        util.between(0, 1, util.move_down(1))
        util.num_marks(444)

        util.between(20, 40, util.insert_mode())
        util.num_marks(444)
    end)
end)
