---@module 'luassert'

local util = require('tests.util')

local lines = {
    '# Heading',
    '',
    '-',
    '',
    '- ',
    '',
    '- [',
    '',
    '- [-',
    '',
    '- [-]',
    '',
    '- [-] ',
    '',
    '- [-] todo',
    '',
    '- text',
    '',
    '# Heading',
    '',
    '>',
    '',
    '> ',
    '',
    '> [',
    '',
    '> [!',
    '',
    '> [!TIP',
    '',
    '> [!TIP]',
    '',
    '> [!TIP] My Tip',
    '',
    '> text',
}

---@param row render.md.test.Row
---@param n integer
---@param col integer
---@param expected lsp.CompletionItem[]
local function assert_items(row, n, col, expected)
    local source = require('render-markdown.integ.source')
    local actual = source.items(0, row:get(n)[1], col) or {}
    table.sort(actual, function(a, b)
        return a.label < b.label
    end)
    assert.same(expected, actual)
end

---@param prefix string
---@param suffix string
---@param label string
---@param detail string
---@param description? string
---@return lsp.CompletionItem
local function item(prefix, suffix, label, detail, description)
    ---@type lsp.CompletionItem
    return {
        kind = 12,
        label = label,
        labelDetails = {
            detail = ' ' .. detail,
            description = description,
        },
        insertText = prefix .. label .. suffix,
    }
end

describe('completions', function()
    it('checkbox', function()
        util.setup.text(lines)

        ---@param prefix string
        ---@return lsp.CompletionItem[]
        local function items(prefix)
            return {
                item(prefix, ' ', '[ ]', '󰄱 ', 'unchecked'),
                item(prefix, ' ', '[-]', '󰥔 ', 'todo'),
                item(prefix, ' ', '[x]', '󰱒 ', 'checked'),
            }
        end

        local row = util.row()
        assert_items(row, 2, 1, items(' '))
        assert_items(row, 2, 2, items(''))
        assert_items(row, 2, 3, items(''))
        assert_items(row, 2, 4, items(''))
        assert_items(row, 2, 5, {})
        assert_items(row, 2, 6, {})
        assert_items(row, 2, 10, {})
        assert_items(row, 2, 6, {})
        assert_items(row, 1, 0, {})
    end)

    it('callout', function()
        util.setup.text(lines)

        ---@param prefix string
        ---@return lsp.CompletionItem[]
        local function items(prefix)
            return {
                item(prefix, '', '[!ABSTRACT]', '󰨸 Abstract'),
                item(prefix, '', '[!ATTENTION]', '󰀪 Attention'),
                item(prefix, '', '[!BUG]', '󰨰 Bug'),
                item(prefix, '', '[!CAUTION]', '󰳦 Caution'),
                item(prefix, '', '[!CHECK]', '󰄬 Check'),
                item(prefix, '', '[!CITE]', '󱆨 Cite'),
                item(prefix, '', '[!DANGER]', '󱐌 Danger'),
                item(prefix, '', '[!DONE]', '󰄬 Done'),
                item(prefix, '', '[!ERROR]', '󱐌 Error'),
                item(prefix, '', '[!EXAMPLE]', '󰉹 Example'),
                item(prefix, '', '[!FAILURE]', '󰅖 Failure'),
                item(prefix, '', '[!FAIL]', '󰅖 Fail'),
                item(prefix, '', '[!FAQ]', '󰘥 Faq'),
                item(prefix, '', '[!HELP]', '󰘥 Help'),
                item(prefix, '', '[!HINT]', '󰌶 Hint'),
                item(prefix, '', '[!IMPORTANT]', '󰅾 Important'),
                item(prefix, '', '[!INFO]', '󰋽 Info'),
                item(prefix, '', '[!MISSING]', '󰅖 Missing'),
                item(prefix, '', '[!NOTE]', '󰋽 Note'),
                item(prefix, '', '[!QUESTION]', '󰘥 Question'),
                item(prefix, '', '[!QUOTE]', '󱆨 Quote'),
                item(prefix, '', '[!SUCCESS]', '󰄬 Success'),
                item(prefix, '', '[!SUMMARY]', '󰨸 Summary'),
                item(prefix, '', '[!TIP]', '󰌶 Tip'),
                item(prefix, '', '[!TLDR]', '󰨸 Tldr'),
                item(prefix, '', '[!TODO]', '󰗡 Todo'),
                item(prefix, '', '[!WARNING]', '󰀪 Warning'),
            }
        end

        local row = util.row()
        assert_items(row, 20, 1, items(' '))
        assert_items(row, 2, 2, items(''))
        assert_items(row, 2, 3, items(''))
        assert_items(row, 2, 4, items(''))
        assert_items(row, 2, 7, items(''))
        assert_items(row, 2, 8, {})
        assert_items(row, 2, 15, {})
        assert_items(row, 2, 6, {})
    end)
end)
