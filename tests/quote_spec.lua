---@module 'luassert'

local util = require('tests.util')

describe('quote', function()
    it('nested', function()
        util.setup.text({
            '> [!IMPORTANT]',
            '>',
            '> Important',
            '>',
            '> > Normal',
            '> > Note',
            '> > > [!CAUTION]',
            '> > > Lookout',
            '> > >',
            '> Important',
            '> > > New',
        })

        local marks, row = util.marks(), util.row()

        local hint = 'RmHint'
        local base = 'RmQuote'
        local err = 'RmError'

        marks:add(row:get(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:get(), row:get(), 2, 14, {
            virt_text = { { '󰅾 Important', hint } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))

        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:get(), row:get(), 2, 3, util.quote(base))
        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:get(), row:get(), 2, 3, util.quote(base))

        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:get(), row:get(), 2, 3, util.quote(base))
        marks:add(row:get(), row:get(), 4, 5, util.quote(err))
        marks:add(row:get(), row:get(), 6, 16, {
            virt_text = { { '󰳦 Caution', err } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:get(), row:get(), 2, 3, util.quote(base))
        marks:add(row:get(), row:get(), 4, 5, util.quote(err))
        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:get(), row:get(), 2, 3, util.quote(base))
        marks:add(row:get(), row:get(), 4, 5, util.quote(err))

        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))

        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:get(), row:get(), 2, 3, util.quote(base))
        marks:add(row:get(), row:get(), 4, 5, util.quote(base))

        util.assert_view(marks, {
            '▋ 󰅾 Important',
            '▋',
            '▋ Important',
            '▋',
            '▋ ▋ Normal',
            '▋ ▋ Note',
            '▋ ▋ ▋ 󰳦 Caution',
            '▋ ▋ ▋ Lookout',
            '▋ ▋ ▋',
            '▋ Important',
            '▋ ▋ ▋ New',
        })
    end)
end)
