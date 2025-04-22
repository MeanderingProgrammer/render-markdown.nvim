---@module 'luassert'

local util = require('tests.util')

describe('callout.md', function()
    it('default', function()
        util.setup.file('demo/callout.md')

        local marks, row = util.marks(), util.row()

        marks:add(row:get(), nil, 0, nil, util.heading.sign(1))
        marks:add(row:get(), row:get(), 0, 1, util.heading.icon(1))
        marks:add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local info = 'RmInfo'
        marks:add(row:inc(), row:get(), 0, 1, util.quote(info))
        marks:add(row:get(), row:get(), 2, 9, {
            virt_text = { { '󰋽 Note', info } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:inc(), row:get(), 0, 1, util.quote(info))
        marks:add(row:inc(), row:get(), 0, 1, util.quote(info))
        marks:add(row:inc(), row:get(), 0, 1, util.quote(info))
        marks:add(row:inc(), row:get(), 0, 1, util.quote(info))

        marks:add(row:inc(2), nil, 0, nil, util.heading.sign(1))
        marks:add(row:get(), row:get(), 0, 1, util.heading.icon(1))
        marks:add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local ok = 'RmSuccess'
        marks:add(row:inc(), row:get(), 0, 1, util.quote(ok))
        marks:add(row:get(), row:get(), 2, 8, {
            virt_text = { { '󰌶 Tip', ok } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:inc(), row:get(), 0, 1, util.quote(ok))
        marks:add(row:inc(), row:get(), 0, 1, util.quote(ok))
        marks:add(row:get(), nil, 2, nil, util.code.sign('lua'))
        marks:add(row:get(), row:get(), 2, 5, util.conceal())
        marks:add(row:get(), nil, 5, nil, util.code.icon('lua'))
        marks:add(row:get(), row:get(), 5, 8, util.conceal())
        marks:add(row:get(), row:inc(), 2, 0, util.code.border('above'))
        marks:add(row:get(), row:get(), 0, 1, util.quote(ok))
        marks:add(row:get(), row:inc(), 2, 0, util.code.bg())
        marks:add(row:get(), row:get(), 0, 1, util.quote(ok))
        marks:add(row:get(), row:get(), 2, 5, util.conceal())
        marks:add(row:get(), row:get(), 2, 5, util.conceal_lines())

        marks:add(row:inc(2), nil, 0, nil, util.heading.sign(1))
        marks:add(row:get(), row:get(), 0, 1, util.heading.icon(1))
        marks:add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local hint = 'RmHint'
        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))
        marks:add(row:get(), row:get(), 2, 14, {
            virt_text = { { '󰅾 Important', hint } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:inc(), row:get(), 0, 1, util.quote(hint))

        marks:add(row:inc(2), nil, 0, nil, util.heading.sign(1))
        marks:add(row:get(), row:get(), 0, 1, util.heading.icon(1))
        marks:add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local warn = 'RmWarn'
        marks:add(row:inc(), row:get(), 0, 1, util.quote(warn))
        marks:add(row:get(), row:get(), 2, 12, {
            virt_text = { { '󰀪 Custom Title', warn } },
            virt_text_pos = 'overlay',
            conceal = '',
        })
        marks:add(row:inc(), row:get(), 0, 1, util.quote(warn))

        marks:add(row:inc(2), nil, 0, nil, util.heading.sign(1))
        marks:add(row:get(), row:get(), 0, 1, util.heading.icon(1))
        marks:add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local err = 'RmError'
        marks:add(row:inc(), row:get(), 0, 1, util.quote(err))
        marks:add(row:get(), row:get(), 2, 12, {
            virt_text = { { '󰳦 Caution', err } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:inc(), row:get(), 0, 1, util.quote(err))

        marks:add(row:inc(2), nil, 0, nil, util.heading.sign(1))
        marks:add(row:get(), row:get(), 0, 1, util.heading.icon(1))
        marks:add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks:add(row:inc(), row:get(), 0, 1, util.quote(err))
        marks:add(row:get(), row:get(), 2, 8, {
            virt_text = { { '󰨰 Bug', err } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:inc(), row:get(), 0, 1, util.quote(err))

        util.assert_view(marks, {
            '󰫎 󰲡 Note',
            '',
            '  ▋ 󰋽 Note',
            '  ▋',
            '  ▋ A regular note',
            '  ▋',
            '  ▋ With a second paragraph',
            '',
            '󰫎 󰲡 Tip',
            '',
            '  ▋ 󰌶 Tip',
            '  ▋',
            '󰢱 ▋ 󰢱 lua',
            "  ▋ print('Standard tip')",
            '',
            '󰫎 󰲡 Important',
            '',
            '  ▋ 󰅾 Important',
            '  ▋ Exceptional info',
            '',
            '󰫎 󰲡 Warning',
            '',
            '  ▋ 󰀪 Custom Title',
            '  ▋ Dastardly surprise',
            '',
            '󰫎 󰲡 Caution',
            '',
            '  ▋ 󰳦 Caution',
            '  ▋ Cautionary tale',
            '',
            '󰫎 󰲡 Bug',
            '',
            '  ▋ 󰨰 Bug',
            '  ▋ Custom bug',
        })
    end)
end)
