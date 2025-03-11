---@module 'luassert'

local util = require('tests.util')

describe('callout.md', function()
    it('default', function()
        util.setup('demo/callout.md')

        local marks, row = util.marks(), util.row()

        local info = 'RenderMarkdownInfo'
        marks:extend(util.heading(row:get(), 1))
        marks:add(util.quote(row:inc(2), '%s ', info))
        marks:add(util.overlay(row:get(), { 2, 9 }, { '󰋽 Note', info }))
        marks:add(util.quote(row:inc(), '%s', info))
        marks:add(util.quote(row:inc(), '%s ', info))
        marks:add(util.quote(row:inc(), '%s', info))
        marks:add(util.quote(row:inc(), '%s ', info))

        local ok = 'RenderMarkdownSuccess'
        marks:extend(util.heading(row:inc(2), 1))
        marks:add(util.quote(row:inc(2), '%s ', ok))
        marks:add(util.overlay(row:get(), { 2, 8 }, { '󰌶 Tip', ok }))
        marks:add(util.quote(row:inc(), '%s', ok))
        marks:add(util.quote(row:inc(), '%s ', ok))
        marks:extend(util.code_language(row:get(), 2, 'lua'))
        marks:add(util.code_row(row:get(), 2))
        marks:add(util.quote(row:inc(), '%s ', ok))
        marks:add(util.code_row(row:get(), 2))
        marks:add(util.quote(row:inc(), '%s ', ok))
        marks:add(util.code_border(row:get(), 2, false))

        local hint = 'RenderMarkdownHint'
        marks:extend(util.heading(row:inc(2), 1))
        marks:add(util.quote(row:inc(2), '%s ', hint))
        marks:add(util.overlay(row:get(), { 2, 14 }, { '󰅾 Important', hint }))
        marks:add(util.quote(row:inc(), '%s ', hint))

        local warn = 'RenderMarkdownWarn'
        marks:extend(util.heading(row:inc(2), 1))
        marks:add(util.quote(row:inc(2), '%s ', warn))
        marks:add(util.overlay(row:get(), { 2, 12 }, { '󰀪 Custom Title', warn }, ''))
        marks:add(util.quote(row:inc(), '%s ', warn))

        local err = 'RenderMarkdownError'
        marks:extend(util.heading(row:inc(2), 1))
        marks:add(util.quote(row:inc(2), '%s ', err))
        marks:add(util.overlay(row:get(), { 2, 12 }, { '󰳦 Caution', err }))
        marks:add(util.quote(row:inc(), '%s ', err))

        marks:extend(util.heading(row:inc(2), 1))
        marks:add(util.quote(row:inc(2), '%s ', err))
        marks:add(util.overlay(row:get(), { 2, 8 }, { '󰨰 Bug', err }))
        marks:add(util.quote(row:inc(), '%s ', err))

        util.assert_view(marks, {
            '󰫎   1 󰲡 Note',
            '    2',
            '    3 ▋ 󰋽 Note',
            '    4 ▋',
            '    5 ▋ A regular note',
            '    6 ▋',
            '    7 ▋ With a second paragraph',
            '    8',
            '󰫎   9 󰲡 Tip',
            '   10',
            '   11 ▋ 󰌶 Tip',
            '   12 ▋',
            '󰢱  13 ▋ 󰢱 lua',
            "   14 ▋ print('Standard tip')",
            '   15 ▋ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
            '   16',
            '󰫎  17 󰲡 Important',
            '   18',
            '   19 ▋ 󰅾 Important',
            '   20 ▋ Exceptional info',
            '   21',
            '󰫎  22 󰲡 Warning',
            '   23',
            '   24 ▋ 󰀪 Custom Title',
            '   25 ▋ Dastardly surprise',
            '   26',
            '󰫎  27 󰲡 Caution',
            '   28',
            '   29 ▋ 󰳦 Caution',
            '   30 ▋ Cautionary tale',
            '   31',
            '󰫎  32 󰲡 Bug',
            '   33',
            '   34 ▋ 󰨰 Bug',
            '   35 ▋ Custom bug',
        })
    end)
end)
