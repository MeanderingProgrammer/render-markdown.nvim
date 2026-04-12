---@module 'luassert'

local util = require('tests.util')

describe('footnote', function()
    it('in shortcut_link', function()
        util.setup.text({
            'Footnote Link [^1 Info]',
            '',
            '[^1 Info]: Some Info',
        })
        local marks = util.marks()
        marks:add({ 0, 0 }, { 14, 23 }, {
            virt_text = { { '󰯔 ¹ ᴵⁿᶠᵒ', 'RmLink' } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        marks:add({ 2, 2 }, { 0, 9 }, {
            virt_text = { { '󰯔 ¹ ᴵⁿᶠᵒ', 'RmLink' } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        util.assert_view(marks, {
            'Footnote Link 󰯔 ¹ ᴵⁿᶠᵒ',
            '',
            '󰯔 ¹ ᴵⁿᶠᵒ: Some Info',
        })
    end)

    it('in link_reference_definition', function()
        util.setup.text({
            'Footnote Link [^1]',
            '',
            '[^1]: Some "Info"',
        })
        local marks = util.marks()
        marks:add({ 0, 0 }, { 14, 18 }, {
            virt_text = { { '󰯔 ¹', 'RmLink' } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        marks:add({ 2, 2 }, { 0, 4 }, {
            virt_text = { { '󰯔 ¹', 'RmLink' } },
            virt_text_pos = 'inline',
            conceal = '',
        })
        util.assert_view(marks, {
            'Footnote Link 󰯔 ¹',
            '',
            '󰯔 ¹: Some "Info"',
        })
    end)
end)
