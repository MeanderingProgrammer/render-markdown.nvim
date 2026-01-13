---@module 'luassert'

local util = require('tests.util')

describe('heading', function()
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

    it('default', function()
        util.setup.text(lines, {
            heading = {},
        })
        util.assert_screen({
            '',
            '󰫎 ① Head 1',
            '',
            '󰫎  ② Head 2',
            '󰫎   ③ H3',
            '󰫎    ④ H4',
            '',
            '󰫎       ⑤ Head 5',
            '',
            '󰫎      ⑥ Head 6',
            '',
            '󰫎 ① Ext Heading',
            '',
            '󰫎 ② Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('border', function()
        util.setup.text(lines, {
            heading = { border = true },
        })
        util.assert_screen({
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎 ① Head 1',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎  ② Head 2',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎   ③ H3',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎    ④ H4',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎       ⑤ Head 5',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎      ⑥ Head 6',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '󰫎 ① Ext Heading',
            '',
            '󰫎 ② Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('border block', function()
        util.setup.text(lines, {
            heading = { border = true, width = 'block' },
        })
        util.assert_screen({
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 ① Head 1',
            '  ▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎  ② Head 2',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄',
            '󰫎   ③ H3',
            '  ▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄',
            '󰫎    ④ H4',
            '  ▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎       ⑤ Head 5',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎      ⑥ Head 6',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '󰫎 ① Ext Heading',
            '',
            '󰫎 ② Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('inline', function()
        util.setup.text(lines, {
            heading = { position = 'inline' },
        })
        util.assert_screen({
            '',
            '󰫎 ① Head 1',
            '',
            '󰫎 ② Head 2',
            '󰫎 ③ H3',
            '󰫎 ④ H4',
            '',
            '󰫎 ⑤ Head 5',
            '',
            '󰫎 ⑥ Head 6',
            '',
            '󰫎 ① Ext Heading',
            '',
            '󰫎 ② Ext Heading 2',
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
            '󰫎 ① Head 1',
            '  ▀▀▀▀▀▀▀▀',
            '',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎  ② Head 2',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄',
            '󰫎   ③ H3',
            '  ▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄',
            '󰫎    ④ H4',
            '  ▀▀▀▀▀▀▀',
            '',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎       ⑤ Head 5',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '  ▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰫎      ⑥ Head 6',
            '  ▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '',
            '󰫎 ① Ext Heading',
            '',
            '󰫎 ② Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('block border inline', function()
        util.setup.text(lines, {
            heading = { width = 'block', border = true, position = 'inline' },
        })
        util.assert_screen({
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 ① Head 1',
            '  ▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 ② Head 2',
            '  ▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄',
            '󰫎 ③ H3',
            '  ▀▀▀▀',
            '  ▄▄▄▄',
            '󰫎 ④ H4',
            '  ▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 ⑤ Head 5',
            '  ▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄',
            '󰫎 ⑥ Head 6',
            '  ▀▀▀▀▀▀▀▀',
            '󰫎 ① Ext Heading',
            '',
            '󰫎 ② Ext Heading 2',
            '    Ext Heading 2 Line 2',
        })
    end)

    it('right', function()
        util.setup.text(lines, {
            heading = { position = 'right' },
        })
        util.assert_screen({
            '',
            '󰫎 Head 1 ①',
            '',
            '󰫎 Head 2 ②',
            '󰫎 H3 ③',
            '󰫎 H4 ④',
            '',
            '󰫎 Head 5 ⑤',
            '',
            '󰫎 Head 6 ⑥',
            '',
            '󰫎 Ext Heading ①',
            '',
            '󰫎 Ext Heading 2 ②',
            '  Ext Heading 2 Line 2',
        })
    end)

    it('block border right', function()
        util.setup.text(lines, {
            heading = { width = 'block', border = true, position = 'right' },
        })
        util.assert_screen({
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎 Head 1 ①',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎 Head 2 ②',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄',
            '󰫎 H3 ③',
            '  ▀▀▀▀▀',
            '  ▄▄▄▄▄',
            '󰫎 H4 ④',
            '  ▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎 Head 5 ⑤',
            '  ▀▀▀▀▀▀▀▀▀',
            '  ▄▄▄▄▄▄▄▄▄',
            '󰫎 Head 6 ⑥',
            '  ▀▀▀▀▀▀▀▀▀',
            '󰫎 Ext Heading ①',
            '',
            '󰫎 Ext Heading 2 ②',
            '  Ext Heading 2 Line 2',
        })
    end)

    it('margin', function()
        util.setup.text(lines, {
            heading = { left_margin = 0.5 },
        })
        util.assert_screen({
            '',
            '󰫎                                     ① Head 1',
            '',
            '󰫎                                      ② Head 2',
            '󰫎                                        ③ H3',
            '󰫎                                         ④ H4',
            '',
            '󰫎                                        ⑤ Head 5',
            '',
            '󰫎                                        ⑥ Head 6',
            '',
            '󰫎                                   ① Ext Heading',
            '',
            '󰫎                              ② Ext Heading 2',
            '                                 Ext Heading 2 Line 2',
        })
    end)
end)
