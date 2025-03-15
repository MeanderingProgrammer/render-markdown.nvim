---@module 'luassert'

local util = require('tests.util')

describe('ad_hoc.md', function()
    it('custom', function()
        util.setup('tests/data/ad_hoc.md')

        local marks, row = util.marks(), util.row()

        marks
            :add(row:get(), nil, 0, nil, util.heading.sign(1))
            :add(row:get(), row:get(), 0, 1, util.heading.icon(1))
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(1))

        marks
            :add(row:inc(), nil, 0, nil, util.heading.sign(2))
            :add(row:get(), row:get(), 0, 0, {
                virt_text = { { '󰲣 ', 'RmH2:RmH2Bg' } },
                virt_text_pos = 'inline',
            })
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(2))
            :add(row:get(), row:get(), 0, 0, {
                virt_text = { { '  ', 'RmH2:RmH2Bg' } },
                virt_text_pos = 'inline',
            })
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(2))
            :add(row:get(), row:get(), 0, 0, {
                virt_text = { { '  ', 'RmH2:RmH2Bg' } },
                virt_text_pos = 'inline',
            })
            :add(row:get(), row:get(), 0, 3, util.conceal())
            :add(row:get(), row:inc(), 0, 0, util.heading.bg(2))

        marks:add(row:inc(), row:get(), 0, 2, util.bullet(1))

        marks
            :add(row:inc(), row:get(), 0, 2, util.bullet(1))
            :add(row:get(), row:get(), 2, 3, util.conceal())
            :add(row:get(), row:get(), 3, 14, util.link('wiki'))
            :add(row:get(), row:get(), 14, 15, util.conceal())

        marks
            :add(row:inc(), row:get(), 0, 2, util.bullet(1))
            :add(row:get(), row:get(), 2, 3, util.conceal())
            :add(row:get(), row:get(), 3, 24, util.link('wiki'))
            :add(row:get(), row:get(), 4, 13, util.conceal())
            :add(row:get(), row:get(), 24, 25, util.conceal())

        marks
            :add(row:inc(), row:get(), 0, 2, util.bullet(1))
            :add(row:get(), row:get(), 2, 3, util.conceal())
            :add(row:get(), row:get(), 2, 20, util.link('email'))
            :add(row:get(), row:get(), 2, 20, util.highlight('link'))
            :add(row:get(), row:get(), 19, 20, util.conceal())

        marks
            :add(row:inc(), row:get(), 0, 2, util.bullet(1))
            :add(row:get(), row:get(), 2, 3, util.conceal())
            :add(row:get(), row:get(), 2, 26, util.link('git'))
            :add(row:get(), row:get(), 2, 26, util.highlight('link'))
            :add(row:get(), row:get(), 25, 26, util.conceal())

        marks:add(row:inc(), row:get(), 0, 2, util.bullet(1))
        marks:add(row:get(), row:get(), 2, 61, util.link('youtube'))

        marks:add(row:inc(), row:get(), 0, 2, util.bullet(1))
        marks:add(row:get(), row:get(), 16, 25, {
            virt_text = { { '¹ ᴵⁿᶠᵒ', 'RmLink' } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        marks:add(row:inc(2), row:get(), 0, 16, util.conceal())
        marks:add(row:inc(2), row:get(), 0, 9, {
            virt_text = { { '¹ ᴵⁿᶠᵒ', 'RmLink' } },
            virt_text_pos = 'inline',
            conceal = '',
        })

        util.assert_view(marks, {
            '󰫎   1 󰲡 Heading',
            '    2',
            '󰫎   3 󰲣 Heading 2 Line 1',
            '    4   Heading 2 Line 2',
            '    5',
            '    6',
            '    7 ● Normal Shortcut',
            '    8 ● 󱗖 Basic One Then normal text',
            '    9 ● 󱗖 With Alias Something important',
            '   10 ● 󰀓 test@example.com Email',
            '   11 ● 󰊤 http://www.github.com/ Bare URL',
            '   12 ● 󰗃 Youtube Link',
            '   13 ● Footnote Link ¹ ᴵⁿᶠᵒ',
            '   14',
            '   15',
            '   16',
            '   17 ¹ ᴵⁿᶠᵒ: Some Info',
        })
    end)
end)
