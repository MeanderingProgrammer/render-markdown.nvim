---@module 'luassert'

local util = require('tests.util')

describe('box_dash_quote.md', function()
    it('default', function()
        util.setup('demo/box_dash_quote.md')

        local marks, row = util.marks(), util.row()

        marks:extend(util.heading(row:get(), 1))

        marks:add(util.conceal(row:inc(2), { 0, 2 }))
        marks:add(util.inline(row:get(), { 2, 5 }, { '󰄱 ', 'RenderMarkdownUnchecked' }, ''))
        marks:add(util.conceal(row:inc(), { 0, 2 }))
        marks:add(util.inline(row:get(), { 2, 5 }, { '󰱒 ', 'RenderMarkdownChecked' }, ''))
        marks:add(util.conceal(row:inc(), { 0, 2 }))
        marks:add(util.inline(row:get(), { 2, 5 }, { '󰥔 ', 'RenderMarkdownTodo' }, ''))
        marks:add(util.bullet(row:inc(), 0, 1))

        marks:add(util.overlay(row:inc(2), { 0 }, { string.rep('─', vim.o.columns), 'RenderMarkdownDash' }))

        marks:add(util.quote(row:inc(2), '  %s ', 'RenderMarkdownQuote'))
        marks:add(util.quote(row:inc(), '  %s ', 'RenderMarkdownQuote'))

        util.assert_view(marks, {
            '󰫎   1 󰲡 Checkbox / Dash / Quote',
            '    2',
            '    3 󰄱  Unchecked Checkbox',
            '    4 󰱒  Checked Checkbox',
            '    5 󰥔  Todo Checkbox',
            '    6 ● Regular List Item',
            '    7',
            '    8 ──────────────────────────────────────────────────────────────────────────',
            '    9',
            '   10   ▋ Quote line 1',
            '   11   ▋ Quote line 2',
        })
    end)
end)
