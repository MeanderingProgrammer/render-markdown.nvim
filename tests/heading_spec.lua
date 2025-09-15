---@module 'luassert'

local util = require('tests.util')

local lines = {
    '',
    '# Head 1',
    '',
    '## Head 2',
    '### H3',
    '#### H4',
    '',
    '  ##### Head 5',
    '',
    '###### Head 6',
    '',
    'Ext Heading',
    '===',
    '',
    'Ext Heading 2',
    'Ext Heading 2 Line 2',
    '---',
}

describe('heading', function()
    it('default', function()
        util.setup.text(lines, {
            heading = {},
        })
        util.assert_screen({
            '',
            '󰫎 󰲡 Head 1',
            '',
            '󰫎  󰲣 Head 2',
            '󰫎   󰲥 H3',
            '󰫎    󰲧 H4',
            '',
            '󰫎       󰲩 Head 5',
            '',
            '󰫎      󰲫 Head 6',
            '',
            '󰫎 󰲡 Ext Heading',
            '',
            '󰫎 󰲣 Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('border', function()
        util.setup.text(lines, {
            heading = { border = true },
        })
        util.assert_screen({
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎 󰲡 Head 1',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎  󰲣 Head 2',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   󰲥 H3',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎    󰲧 H4',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎       󰲩 Head 5',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎      󰲫 Head 6',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '󰫎 󰲡 Ext Heading',
            '',
            '󰫎 󰲣 Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('border block', function()
        util.setup.text(lines, {
            heading = { border = true, width = 'block' },
        })
        util.assert_screen({
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 󰲡 Head 1',
            '  ▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎  󰲣 Head 2',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄',
            '󰫎   󰲥 H3',
            '  ▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄',
            '󰫎    󰲧 H4',
            '  ▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎       󰲩 Head 5',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎      󰲫 Head 6',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '󰫎 󰲡 Ext Heading',
            '',
            '󰫎 󰲣 Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('inline', function()
        util.setup.text(lines, {
            heading = { position = 'inline' },
        })
        util.assert_screen({
            '',
            '󰫎 󰲡 Head 1',
            '',
            '󰫎 󰲣 Head 2',
            '󰫎 󰲥 H3',
            '󰫎 󰲧 H4',
            '',
            '󰫎 󰲩 Head 5',
            '',
            '󰫎 󰲫 Head 6',
            '',
            '󰫎 󰲡 Ext Heading',
            '',
            '󰫎 󰲣 Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('block border virtual', function()
        util.setup.text(lines, {
            heading = { width = 'block', border = true, border_virtual = true },
        })
        util.assert_screen({
            '',
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 󰲡 Head 1',
            '  ▀▀▀▀▀▀▀▀',
            '',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎  󰲣 Head 2',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄',
            '󰫎   󰲥 H3',
            '  ▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄',
            '󰫎    󰲧 H4',
            '  ▀▀▀▀▀▀▀',
            '',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎       󰲩 Head 5',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎      󰲫 Head 6',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '󰫎 󰲡 Ext Heading',
            '',
            '󰫎 󰲣 Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('block border inline', function()
        util.setup.text(lines, {
            heading = { width = 'block', border = true, position = 'inline' },
        })
        util.assert_screen({
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 󰲡 Head 1',
            '  ▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 󰲣 Head 2',
            '  ▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄',
            '󰫎 󰲥 H3',
            '  ▀▀▀▀',
            '  ▄▄▄▄',
            '󰫎 󰲧 H4',
            '  ▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 󰲩 Head 5',
            '  ▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 󰲫 Head 6',
            '  ▀▀▀▀▀▀▀▀',
            '󰫎 󰲡 Ext Heading',
            '',
            '󰫎 󰲣 Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('right', function()
        util.setup.text(lines, {
            heading = { position = 'right' },
        })
        util.assert_screen({
            '',
            '󰫎 Head 1 󰲡',
            '',
            '󰫎 Head 2 󰲣',
            '󰫎 H3 󰲥',
            '󰫎 H4 󰲧',
            '',
            '󰫎 Head 5 󰲩',
            '',
            '󰫎 Head 6 󰲫',
            '',
            '󰫎 Ext Heading 󰲡',
            '',
            '󰫎 Ext Heading 2 󰲣',
            '  Ext Heading 2 Line 2',
        })
    end)

    it('block border right', function()
        util.setup.text(lines, {
            heading = { width = 'block', border = true, position = 'right' },
        })
        util.assert_screen({
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎 Head 1 󰲡',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎 Head 2 󰲣',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄',
            '󰫎 H3 󰲥',
            '  ▀▀▀▀▀',
            '  ▄▄▄▄▄',
            '󰫎 H4 󰲧',
            '  ▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎 Head 5 󰲩',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎 Head 6 󰲫',
            '  ▀▀▀▀▀▀▀▀▀',
            '󰫎 Ext Heading 󰲡',
            '',
            '󰫎 Ext Heading 2 󰲣',
            '  Ext Heading 2 Line 2',
        })
    end)

    it('margin', function()
        util.setup.text(lines, {
            heading = { left_margin = 0.5 },
        })
        util.assert_screen({
            '',
            '󰫎                                     󰲡 Head 1',
            '',
            '󰫎                                      󰲣 Head 2',
            '󰫎                                        󰲥 H3',
            '󰫎                                         󰲧 H4',
            '',
            '󰫎                                        󰲩 Head 5',
            '',
            '󰫎                                        󰲫 Head 6',
            '',
            '󰫎                                   󰲡 Ext Heading',
            '',
            '󰫎                              󰲣 Ext Heading 2',
            '                                 Ext Heading 2 Line 2',
        })
    end)
end)
