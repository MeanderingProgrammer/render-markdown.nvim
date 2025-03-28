---@module 'luassert'

local util = require('tests.util')

describe('callout.md', function()
    it('default', function()
        util.setup.file('demo/callout.md')

        local marks, row = util.marks(), util.row()

        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local info = 'RmInfo'
        marks
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', info))
            :add(row:get(), row:get(), 2, 9, {
                virt_text = { { '󰋽 Note', info } },
                virt_text_pos = 'overlay',
            })
            :add(row:inc(), row:get(), 0, 1, util.quote('%s', info))
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', info))
            :add(row:inc(), row:get(), 0, 1, util.quote('%s', info))
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', info))

        marks
            :add(row:inc(2), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local ok = 'RmSuccess'
        marks
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', ok))
            :add(row:get(), row:get(), 2, 8, {
                virt_text = { { '󰌶 Tip', ok } },
                virt_text_pos = 'overlay',
            })
            :add(row:inc(), row:get(), 0, 1, util.quote('%s', ok))
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', ok))
            :add(row:get(), nil, 2, nil, util.code.sign('lua'))
            :add(row:get(), row:get(), 2, 5, util.conceal())
            :add(row:get(), nil, 5, nil, util.code.icon('lua'))
            :add(row:get(), row:get(), 5, 8, util.conceal())
            :add(row:get(), row:inc(), 2, 0, util.code.border('above'))
            :add(row:get(), row:get(), 0, 2, util.quote('%s ', ok))
            :add(row:get(), row:inc(), 2, 0, util.code.bg())
            :add(row:get(), row:get(), 0, 2, util.quote('%s ', ok))
            :add(row:get(), row:get(), 2, 5, util.conceal())
            :add(row:get(), row:get(), 2, 5, util.conceal_lines())

        marks
            :add(row:inc(2), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local hint = 'RmHint'
        marks
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', hint))
            :add(row:get(), row:get(), 2, 14, {
                virt_text = { { '󰅾 Important', hint } },
                virt_text_pos = 'overlay',
            })
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', hint))

        marks
            :add(row:inc(2), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local warn = 'RmWarn'
        marks
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', warn))
            :add(row:get(), row:get(), 2, 12, {
                virt_text = { { '󰀪 Custom Title', warn } },
                virt_text_pos = 'overlay',
                conceal = '',
            })
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', warn))

        marks
            :add(row:inc(2), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        local err = 'RmError'
        marks
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', err))
            :add(row:get(), row:get(), 2, 12, {
                virt_text = { { '󰳦 Caution', err } },
                virt_text_pos = 'overlay',
            })
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', err))

        marks
            :add(row:inc(2), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', err))
            :add(row:get(), row:get(), 2, 8, {
                virt_text = { { '󰨰 Bug', err } },
                virt_text_pos = 'overlay',
            })
            :add(row:inc(), row:get(), 0, 2, util.quote('%s ', err))

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
