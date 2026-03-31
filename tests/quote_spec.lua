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

        local levels = {
            'RmHint',
            'RmQuote2',
            'RmError',
            'RmQuote3',
        }

        marks:add(row:get(0, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 14 }, {
            virt_text = { { '󰅾 Important', levels[1] } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))

        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 3 }, util.quote(levels[2]))
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 3 }, util.quote(levels[2]))

        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 3 }, util.quote(levels[2]))
        marks:add(row:get(0, 0), { 4, 5 }, util.quote(levels[3]))
        marks:add(row:get(0, 0), { 6, 16 }, {
            virt_text = { { '󰳦 Caution', levels[3] } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 3 }, util.quote(levels[2]))
        marks:add(row:get(0, 0), { 4, 5 }, util.quote(levels[3]))
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 3 }, util.quote(levels[2]))
        marks:add(row:get(0, 0), { 4, 5 }, util.quote(levels[3]))

        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))

        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 3 }, util.quote(levels[2]))
        marks:add(row:get(0, 0), { 4, 5 }, util.quote(levels[4]))

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

    it('heading', function()
        util.setup.text({
            '> # Heading',
            '>',
            '> > [!TIP]',
            '> >',
            '> > Text',
        })

        local marks, row = util.marks(), util.row()

        local levels = {
            'RmQuote1',
            'RmSuccess',
        }

        marks:add(row:get(0, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0), 2, util.heading.sign(1))
        marks:add(row:get(0, 0), { 2, 3 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 2, 0 }, util.heading.bg(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.quote(levels[1]))

        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 3 }, util.quote(levels[2]))
        marks:add(row:get(0, 0), { 4, 10 }, {
            virt_text = { { '󰌶 Tip', levels[2] } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 3 }, util.quote(levels[2]))
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(levels[1]))
        marks:add(row:get(0, 0), { 2, 3 }, util.quote(levels[2]))

        util.assert_view(marks, {
            '󰫎 ▋ 󰲡 Heading',
            '  ▋',
            '  ▋ ▋ 󰌶 Tip',
            '  ▋ ▋',
            '  ▋ ▋ Text',
        })
    end)
end)
