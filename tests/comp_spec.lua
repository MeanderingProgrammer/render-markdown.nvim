---@module 'luassert'

local util = require('tests.util')

---@param row integer
---@param col integer
---@param expected lsp.CompletionItem[]
local function assert_items(row, col, expected)
    local source = require('render-markdown.integ.source')
    local actual = source.items(0, row, col) or {}
    table.sort(actual, function(a, b)
        return a.label < b.label
    end)
    assert.are.same(expected, actual)
end

---@param prefix string
---@param label string
---@param detail string
---@param description? string
---@return lsp.CompletionItem
local function item(prefix, label, detail, description)
    ---@type lsp.CompletionItem
    return {
        kind = 12,
        label = prefix .. label,
        labelDetails = {
            detail = detail,
            description = description,
        },
    }
end

describe('comp.md', function()
    it('checkbox', function()
        util.setup('tests/data/comp.md')

        ---@param prefix string
        ---@return lsp.CompletionItem[]
        local function items(prefix)
            return {
                item(prefix, '[ ] ', '󰄱 ', 'unchecked'),
                item(prefix, '[-] ', '󰥔 ', 'todo'),
                item(prefix, '[x] ', '󰱒 ', 'checked'),
            }
        end

        assert_items(2, 1, items(' '))
        assert_items(4, 2, items(''))
        assert_items(6, 3, items(''))
        assert_items(8, 4, items(''))
        assert_items(10, 5, {})
        assert_items(12, 6, {})
        assert_items(14, 10, {})
        assert_items(16, 6, {})
        assert_items(17, 0, {})
    end)

    it('callout', function()
        util.setup('tests/data/comp.md')

        ---@param prefix string
        ---@return lsp.CompletionItem[]
        local function items(prefix)
            return {
                item(prefix, '[!ABSTRACT]', '󰨸 Abstract'),
                item(prefix, '[!ATTENTION]', '󰀪 Attention'),
                item(prefix, '[!BUG]', '󰨰 Bug'),
                item(prefix, '[!CAUTION]', '󰳦 Caution'),
                item(prefix, '[!CHECK]', '󰄬 Check'),
                item(prefix, '[!CITE]', '󱆨 Cite'),
                item(prefix, '[!DANGER]', '󱐌 Danger'),
                item(prefix, '[!DONE]', '󰄬 Done'),
                item(prefix, '[!ERROR]', '󱐌 Error'),
                item(prefix, '[!EXAMPLE]', '󰉹 Example'),
                item(prefix, '[!FAILURE]', '󰅖 Failure'),
                item(prefix, '[!FAIL]', '󰅖 Fail'),
                item(prefix, '[!FAQ]', '󰘥 Faq'),
                item(prefix, '[!HELP]', '󰘥 Help'),
                item(prefix, '[!HINT]', '󰌶 Hint'),
                item(prefix, '[!IMPORTANT]', '󰅾 Important'),
                item(prefix, '[!INFO]', '󰋽 Info'),
                item(prefix, '[!MISSING]', '󰅖 Missing'),
                item(prefix, '[!NOTE]', '󰋽 Note'),
                item(prefix, '[!QUESTION]', '󰘥 Question'),
                item(prefix, '[!QUOTE]', '󱆨 Quote'),
                item(prefix, '[!SUCCESS]', '󰄬 Success'),
                item(prefix, '[!SUMMARY]', '󰨸 Summary'),
                item(prefix, '[!TIP]', '󰌶 Tip'),
                item(prefix, '[!TLDR]', '󰨸 Tldr'),
                item(prefix, '[!TODO]', '󰗡 Todo'),
                item(prefix, '[!WARNING]', '󰀪 Warning'),
            }
        end

        assert_items(20, 1, items(' '))
        assert_items(22, 2, items(''))
        assert_items(24, 3, items(''))
        assert_items(26, 4, items(''))
        assert_items(28, 7, items(''))
        assert_items(30, 8, {})
        assert_items(32, 15, {})
        assert_items(34, 6, {})
    end)
end)
