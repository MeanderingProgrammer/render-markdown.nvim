---@module 'luassert'

local util = require('tests.util')

describe('table.md conceallevel', function()
    it('0', function()
        util.setup('tests/data/table.md', {
            win_options = { conceallevel = { rendered = 0 } },
        })
        util.assert_screen({
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬──────────────────────────┐',
            '    3 │ Heading 1 │ `Heading 2`              │',
            '    4 ├───────────┼─────────────────────────━┤',
            '    5 │ `Item 行` │ 󰖟 [link](https://行.com) │',
            '    6 │ &lt;1&gt; │ ==Itém 2==               │',
            '      └───────────┴──────────────────────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)

    it('1', function()
        util.setup('tests/data/table.md', {
            win_options = { conceallevel = { rendered = 1 } },
        })
        util.assert_screen({
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬────────────────────────┐',
            '    3 │ Heading 1 │             Heading 2  │',
            '    4 ├───────────┼───────────────────────━┤',
            '    5 │  Item 行  │            󰖟  link     │',
            '    6 │ <1>       │                Itém 2  │',
            '      └───────────┴────────────────────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)

    it('2', function()
        util.setup('tests/data/table.md', {
            win_options = { conceallevel = { rendered = 2 } },
        })
        util.assert_screen({
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬────────────────────────┐',
            '    3 │ Heading 1 │              Heading 2 │',
            '    4 ├───────────┼───────────────────────━┤',
            '    5 │ Item 行   │                 󰖟 link │',
            '    6 │ <1>       │                 Itém 2 │',
            '      └───────────┴────────────────────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)

    it('3', function()
        util.setup('tests/data/table.md', {
            win_options = { conceallevel = { rendered = 3 } },
        })
        util.assert_screen({
            '󰫎   1 󰲡 Table with Inline',
            '    2',
            '      ┌───────────┬────────────────────────┐',
            '    3 │ Heading 1 │              Heading 2 │',
            '    4 ├───────────┼───────────────────────━┤',
            '    5 │ Item 行   │                 󰖟 link │',
            '    6 │ 1         │                 Itém 2 │',
            '      └───────────┴────────────────────────┘',
            '    7',
            '󰫎   8 󰲡 Table no Inline',
            '    9',
            '      ┌───────────┬───────────┐',
            '   10 │ Heading 1 │ Heading 2 │',
            '   11 ├───────────┼───────────┤',
            '   12 │ Item 1    │ Item 2    │',
            '      └───────────┴───────────┘',
        })
    end)
end)
