---@module 'luassert'

local util = require('tests.util')

local lines = {
    '',
    '| Heading 1 | `Heading 2`            |',
    '| --------- | ---------------------: |',
    '| `Item 行` | [link](https://行.com) |',
    '| &lt;1&gt; | ==Itém 2==             |',
    '',
    '| Heading 1 | Heading 2 |',
    '| --------- | --------- |',
    '| Item 1    | Item 2    |',
}

describe('table conceallevel', function()
    it('0', function()
        util.setup.text(lines, {
            win_options = { conceallevel = { rendered = 0 } },
        })
        util.assert_screen({
            '┌───────────┬──────────────────────────┐',
            '│ Heading 1 │ `Heading 2`              │',
            '├───────────┼─────────────────────────━┤',
            '│ `Item 行` │ 󰖟 [link](https://行.com) │',
            '│ &lt;1&gt; │ ==Itém 2==               │',
            '└───────────┴──────────────────────────┘',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        })
    end)

    it('1', function()
        util.setup.text(lines, {
            win_options = { conceallevel = { rendered = 1 } },
        })
        util.assert_screen({
            '┌───────────┬────────────────────────┐',
            '│ Heading 1 │             Heading 2  │',
            '├───────────┼───────────────────────━┤',
            '│  Item 行  │            󰖟  link     │',
            '│ <1>       │                Itém 2  │',
            '└───────────┴────────────────────────┘',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        })
    end)

    it('2', function()
        util.setup.text(lines, {
            win_options = { conceallevel = { rendered = 2 } },
        })
        util.assert_screen({
            '┌───────────┬────────────────────────┐',
            '│ Heading 1 │              Heading 2 │',
            '├───────────┼───────────────────────━┤',
            '│ Item 行   │                 󰖟 link │',
            '│ <1>       │                 Itém 2 │',
            '└───────────┴────────────────────────┘',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        })
    end)

    it('3', function()
        util.setup.text(lines, {
            win_options = { conceallevel = { rendered = 3 } },
        })
        util.assert_screen({
            '┌───────────┬────────────────────────┐',
            '│ Heading 1 │              Heading 2 │',
            '├───────────┼───────────────────────━┤',
            '│ Item 行   │                 󰖟 link │',
            '│ 1         │                 Itém 2 │',
            '└───────────┴────────────────────────┘',
            '┌───────────┬───────────┐',
            '│ Heading 1 │ Heading 2 │',
            '├───────────┼───────────┤',
            '│ Item 1    │ Item 2    │',
            '└───────────┴───────────┘',
        })
    end)
end)
