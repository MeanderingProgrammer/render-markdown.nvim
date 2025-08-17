---@module 'luassert'

local util = require('tests.util')

describe('ad hoc', function()
    it('setext', function()
        util.setup.text({
            'Heading 2 Line 1',
            'Heading 2 Line 2',
            '---',
        })
        local marks = util.marks()
        marks:add(0, 0, util.heading.sign(2))
        marks:add(0, 0, {
            virt_text = { { '󰲣 ', 'RmH2:RmH2Bg' } },
            virt_text_pos = 'inline',
        })
        marks:add({ 0, 1 }, { 0, 0 }, util.heading.bg(2))
        marks:add(1, 0, {
            virt_text = { { '  ', 'RmH2:RmH2Bg' } },
            virt_text_pos = 'inline',
        })
        marks:add({ 1, 2 }, { 0, 0 }, util.heading.bg(2))
        marks:add(2, 0, {
            virt_text = { { '  ', 'RmH2:RmH2Bg' } },
            virt_text_pos = 'inline',
        })
        marks:add({ 2, 2 }, { 0, 3 }, util.conceal())
        marks:add({ 2, 2 }, { 0, 3 }, util.conceal_lines())
        marks:add({ 2, 3 }, { 0, 0 }, util.heading.bg(2))
        util.assert_view(marks, {
            '󰫎 󰲣 Heading 2 Line 1',
            '    Heading 2 Line 2',
        })
    end)

    it('shortcut', function()
        util.setup.text({ '[Normal Shortcut]' })
        local marks = util.marks()
        util.assert_view(marks, { 'Normal Shortcut' })
    end)

    it('image', function()
        util.setup.text({ '![test](test.png)' })
        local marks = util.marks()
        marks:add(0, 0, util.link('image'))
        util.assert_view(marks, { '󰥶 test' })
    end)

    it('wikilink', function()
        util.setup.text({ '[[Basic One]] Then normal text' })
        local marks = util.marks()
        marks:add({ 0, 0 }, { 0, 2 }, util.conceal())
        marks:add(0, 2, util.link('wiki'))
        marks:add({ 0, 0 }, { 11, 13 }, util.conceal())
        util.assert_view(marks, { '󱗖 Basic One Then normal text' })
    end)

    it('wikilink with alias', function()
        util.setup.text({ '[[Nickname|With Alias]] Something important' })
        local marks = util.marks()
        marks:add({ 0, 0 }, { 0, 2 }, util.conceal())
        marks:add(0, 2, util.link('wiki'))
        marks:add({ 0, 0 }, { 2, 11 }, util.conceal())
        marks:add({ 0, 0 }, { 21, 23 }, util.conceal())
        util.assert_view(marks, { '󱗖 With Alias Something important' })
    end)

    it('wikilink media', function()
        util.setup.text({ '![[test.png]]' })
        local marks = util.marks()
        marks:add({ 0, 0 }, { 1, 3 }, util.conceal())
        marks:add(0, 3, util.link('wiki'))
        marks:add({ 0, 0 }, { 11, 13 }, util.conceal())
        util.assert_view(marks, { '󱗖 test.png' })
    end)

    it('email', function()
        util.setup.text({ '<test@example.com> Email' })
        local marks = util.marks()
        marks:add(0, 0, util.link('email'))
        marks:add({ 0, 0 }, { 0, 1 }, util.conceal())
        marks:add({ 0, 0 }, { 0, 18 }, util.highlight('link'))
        marks:add({ 0, 0 }, { 17, 18 }, util.conceal())
        util.assert_view(marks, { '󰀓 test@example.com Email' })
    end)

    it('bare url', function()
        util.setup.text({ '<http://www.github.com/> Bare URL' })
        local marks = util.marks()
        marks:add(0, 0, util.link('git'))
        marks:add({ 0, 0 }, { 0, 1 }, util.conceal())
        marks:add({ 0, 0 }, { 0, 24 }, util.highlight('link'))
        marks:add({ 0, 0 }, { 23, 24 }, util.conceal())
        util.assert_view(marks, { '󰊤 http://www.github.com/ Bare URL' })
    end)

    it('youtube', function()
        util.setup.text({
            '[Youtube Link](https://www.youtube.com/watch?v=dQw4w9WgXcQ)',
        })
        local marks = util.marks()
        marks:add(0, 0, util.link('youtube'))
        util.assert_view(marks, { '󰗃 Youtube Link' })
    end)

    it('footnote', function()
        util.setup.text({
            'Footnote Link [^1 Info]',
            '[^1 Info]: Some Info',
        })
        local marks = util.marks()
        marks:add({ 0, 0 }, { 14, 23 }, {
            virt_text = { { '¹ ᴵⁿᶠᵒ', 'RmLink' } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        marks:add({ 1, 1 }, { 0, 9 }, {
            virt_text = { { '¹ ᴵⁿᶠᵒ', 'RmLink' } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        util.assert_view(marks, {
            'Footnote Link ¹ ᴵⁿᶠᵒ',
            '¹ ᴵⁿᶠᵒ: Some Info',
        })
    end)

    it('html comment', function()
        util.setup.text({ '<!-- comment -->' })
        local marks = util.marks()
        marks:add({ 0, 0 }, { 0, 16 }, util.conceal())
        util.assert_view(marks, { '' })
    end)
end)
