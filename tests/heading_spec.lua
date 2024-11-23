---@module 'luassert'

local util = require('tests.util')

describe('heading.md', function()
    it('default', function()
        util.setup('tests/data/heading.md', { heading = {} })

        util.assert_screen({
            '󰫎   1 󰲡 Head 1',
            '    2',
            '󰫎   3  󰲣 Head 2',
            '󰫎   4   󰲥 H3',
            '󰫎   5    󰲧 H4',
            '    6',
            '󰫎   7     󰲩 Head 5',
            '    8',
            '󰫎   9      󰲫 Head 6',
            '   10',
            '󰫎  11 󰲡 Ext Heading',
            '   12',
            '   13',
            '󰫎  14 󰲣 Ext Heading 2',
            '   15   Ext Heading 2 Line 2',
            '   16',
        })
    end)

    it('border', function()
        util.setup('tests/data/heading.md', { heading = { border = true } })

        util.assert_screen({
            '󰫎   1 󰲡 Head 1',
            '    2',
            '      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   3  󰲣 Head 2',
            '      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   4   󰲥 H3',
            '      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   5    󰲧 H4',
            '    6 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   7     󰲩 Head 5',
            '    8 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   9      󰲫 Head 6',
            '   10 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '󰫎  11 󰲡 Ext Heading',
            '   12',
            '   13',
            '󰫎  14 󰲣 Ext Heading 2',
            '   15   Ext Heading 2 Line 2',
            '   16',
        })
    end)

    it('border block', function()
        util.setup('tests/data/heading.md', { heading = { border = true, width = 'block' } })

        util.assert_screen({
            '󰫎   1 󰲡 Head 1',
            '    2',
            '      ▄▄▄▄▄▄▄▄▄',
            '󰫎   3  󰲣 Head 2',
            '      ▀▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄',
            '󰫎   4   󰲥 H3',
            '      ▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄',
            '󰫎   5    󰲧 H4',
            '    6 ▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   7     󰲩 Head 5',
            '    8 ▀▀▀▀▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   9      󰲫 Head 6',
            '   10 ▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '󰫎  11 󰲡 Ext Heading',
            '   12',
            '   13',
            '󰫎  14 󰲣 Ext Heading 2',
            '   15   Ext Heading 2 Line 2',
            '   16',
        })
    end)

    it('inline', function()
        util.setup('tests/data/heading.md', { heading = { position = 'inline' } })

        util.assert_screen({
            '󰫎   1 󰲡 Head 1',
            '    2',
            '󰫎   3 󰲣 Head 2',
            '󰫎   4 󰲥 H3',
            '󰫎   5 󰲧 H4',
            '    6',
            '󰫎   7 󰲩 Head 5',
            '    8',
            '󰫎   9 󰲫 Head 6',
            '   10',
            '󰫎  11 󰲡 Ext Heading',
            '   12',
            '   13',
            '󰫎  14 󰲣 Ext Heading 2',
            '   15   Ext Heading 2 Line 2',
            '   16',
        })
    end)

    it('border block inline', function()
        util.setup('tests/data/heading.md', { heading = { border = true, width = 'block', position = 'inline' } })

        util.assert_screen({
            '󰫎   1 󰲡 Head 1',
            '    2',
            '      ▄▄▄▄▄▄▄▄',
            '󰫎   3 󰲣 Head 2',
            '      ▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄',
            '󰫎   4 󰲥 H3',
            '      ▀▀▀▀',
            '      ▄▄▄▄',
            '󰫎   5 󰲧 H4',
            '    6 ▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄',
            '󰫎   7 󰲩 Head 5',
            '    8 ▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄',
            '󰫎   9 󰲫 Head 6',
            '   10 ▀▀▀▀▀▀▀▀',
            '󰫎  11 󰲡 Ext Heading',
            '   12',
            '   13',
            '󰫎  14 󰲣 Ext Heading 2',
            '   15   Ext Heading 2 Line 2',
            '   16',
        })
    end)

    it('right', function()
        util.setup('tests/data/heading.md', { heading = { position = 'right' } })

        util.assert_screen({
            '󰫎   1 Head 1 󰲡',
            '    2',
            '󰫎   3 Head 2 󰲣',
            '󰫎   4 H3 󰲥',
            '󰫎   5 H4 󰲧',
            '    6',
            '󰫎   7 Head 5 󰲩',
            '    8',
            '󰫎   9 Head 6 󰲫',
            '   10',
            '󰫎  11 Ext Heading 󰲡',
            '   12',
            '   13',
            '󰫎  14 Ext Heading 2 󰲣',
            '   15 Ext Heading 2 Line 2',
            '   16',
        })
    end)

    it('border block right', function()
        util.setup('tests/data/heading.md', { heading = { border = true, width = 'block', position = 'right' } })

        util.assert_screen({
            '󰫎   1 Head 1 󰲡',
            '    2',
            '      ▄▄▄▄▄▄▄▄▄',
            '󰫎   3 Head 2 󰲣',
            '      ▀▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄',
            '󰫎   4 H3 󰲥',
            '      ▀▀▀▀▀',
            '      ▄▄▄▄▄',
            '󰫎   5 H4 󰲧',
            '    6 ▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄▄',
            '󰫎   7 Head 5 󰲩',
            '    8 ▀▀▀▀▀▀▀▀▀',
            '      ▄▄▄▄▄▄▄▄▄',
            '󰫎   9 Head 6 󰲫',
            '   10 ▀▀▀▀▀▀▀▀▀',
            '󰫎  11 Ext Heading 󰲡',
            '   12',
            '   13',
            '󰫎  14 Ext Heading 2 󰲣',
            '   15 Ext Heading 2 Line 2',
            '   16',
        })
    end)
end)
