---@module 'luassert'

local util = require('tests.util')

describe('table wrapping', function()
    local lines = {
        'BEFORE',
        '',
        '| Name | Description |',
        '| --- | --- |',
        '| **bold** | Here is a long description with [a link](https://example.com) and `some code` and 行行行. |',
        '| short | Another very long description which should wrap into several lines neatly. |',
        '',
        'AFTER',
    }
    local rendered = {
        'BEFORE',
        '┌───────┬──────────────────────────────┐',
        '│ Name  │ Description                  │',
        '├───────┼──────────────────────────────┤',
        '│ bold  │ Here is a long description   │',
        '│       │ with 󰖟 a link and some code  │',
        '│       │ and 行行行.                  │',
        '│ short │ Another very long            │',
        '│       │ description which should     │',
        '│       │ wrap into several lines      │',
        '│       │ neatly.                      │',
        '└───────┴──────────────────────────────┘',
        'AFTER',
    }
    local mixed = {
        'BEFORE',
        '',
        '| A | B | C |',
        '| :- | :-: | -: |',
        '| x | y | short |',
        '| z | w | one two three four five six seven eight nine ten |',
        '| a | b | end |',
        '',
        'AFTER',
    }
    local mixed_rendered = {
        'BEFORE',
        '┌───┬───┬──────────────────────────────┐',
        '│ A │ B │                            C │',
        '├━──┼━─━┼─────────────────────────────━┤',
        '│ x │ y │                        short │',
        '│ z │ w │  one two three four five six │',
        '│   │   │         seven eight nine ten │',
        '│ a │ b │                          end │',
        '└───┴───┴──────────────────────────────┘',
        'AFTER',
    }

    before_each(function()
        vim.o.columns = 40
        vim.o.wrap = true
        vim.o.number = false
        vim.o.signcolumn = 'no'
    end)

    it('trimmed', function()
        util.setup.text(lines, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen(rendered)
    end)

    it('padded', function()
        util.setup.text(lines, { pipe_table = { cell = 'padded' } })
        util.assert_screen(rendered)
    end)

    it('nowrap', function()
        vim.o.wrap = false
        util.setup.text(lines, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen(rendered)
        assert.is_false(vim.o.wrap)
    end)

    it('fitting table', function()
        util.setup.text({
            '',
            '| A | B |',
            '| - | - |',
            '| x | y |',
            '',
        }, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen({
            '┌───┬───┐',
            '│ A │ B │',
            '├───┼───┤',
            '│ x │ y │',
            '└───┴───┘',
        })
    end)

    it('concealed destination wider than the window', function()
        util.setup.text({
            '',
            '| A | B |',
            '| - | - |',
            '| x | [link](https://example.com/a/long/destination/that/exceeds/the/window) |',
            'AFTER',
        }, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen({
            '┌───┬────────┐',
            '│ A │ B      │',
            '├───┼────────┤',
            '│ x │ 󰖟 link │',
            '└───┴────────┘',
            'AFTER',
        })
    end)

    it('delimiter wider than the window', function()
        util.setup.text({
            'BEFORE',
            '',
            '| A | B |',
            '| - | ------------------------------------------------------------ |',
            '| x | y |',
            '',
            'AFTER',
        }, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen({
            'BEFORE',
            '┌───┬───┐',
            '│ A │ B │',
            '├───┼───┤',
            '│ x │ y │',
            '└───┴───┘',
            'AFTER',
        })
    end)

    it('mixed rows and alignments', function()
        util.setup.text(mixed, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen(mixed_rendered)
    end)

    it('mixed rows with nowrap', function()
        vim.o.wrap = false
        util.setup.text(mixed, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen(mixed_rendered)
    end)

    it('cursor on a fitting row', function()
        util.setup.text(mixed, { pipe_table = { cell = 'trimmed' } })
        vim.api.nvim_win_set_cursor(0, { 5, 0 })
        vim.cmd('doautocmd CursorMoved')
        vim.wait(0)
        util.assert_screen(mixed_rendered)
    end)

    it('source padding with nowrap', function()
        vim.o.wrap = false
        util.setup.text({
            'BEFORE',
            '',
            '| A | B |',
            '| - | - |',
            '| x | padded                                                                     |',
            '| y | one two three four five six seven eight nine ten |',
            '',
            'AFTER',
        }, { pipe_table = { cell = 'padded' } })
        vim.api.nvim_win_set_cursor(0, { 5, 0 })
        vim.cmd('doautocmd CursorMoved')
        vim.wait(0)
        util.assert_screen({
            'BEFORE',
            '┌───┬──────────────────────────────────┐',
            '│ A │ B                                │',
            '├───┼──────────────────────────────────┤',
            '│ x │ padded                           │',
            '│ y │ one two three four five six      │',
            '│   │ seven eight nine ten             │',
            '└───┴──────────────────────────────────┘',
            'AFTER',
        })
    end)

    it('inline code decorations at the cell end', function()
        util.setup.text({
            'BEFORE',
            '',
            '| A | B |',
            '| - | - |',
            '| x | one two three four five six seven eight `code` |',
            '',
            'AFTER',
        }, {
            pipe_table = { cell = 'trimmed' },
            code = { inline_left = '(', inline_right = ')' },
        })
        util.assert_screen({
            'BEFORE',
            '┌───┬──────────────────────────────────┐',
            '│ A │ B                                │',
            '├───┼──────────────────────────────────┤',
            '│ x │ one two three four five six      │',
            '│   │ seven eight (code)               │',
            '└───┴──────────────────────────────────┘',
            'AFTER',
        })
    end)

    it('virtual borders', function()
        util.setup.text(mixed, {
            pipe_table = {
                cell = 'trimmed',
                border_virtual = true,
            },
        })
        util.assert_screen({
            'BEFORE',
            '',
            '┌───┬───┬──────────────────────────────┐',
            '│ A │ B │                            C │',
            '├━──┼━─━┼─────────────────────────────━┤',
            '│ x │ y │                        short │',
            '│ z │ w │  one two three four five six │',
            '│   │   │         seven eight nine ten │',
            '│ a │ b │                          end │',
            '└───┴───┴──────────────────────────────┘',
            '',
            'AFTER',
        })
    end)

    it('quote', function()
        util.setup.text({
            'BEFORE',
            '',
            '> | A | B |',
            '> | - | - |',
            '> | x | one two three four five six seven eight nine ten |',
            '',
            'AFTER',
        }, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen({
            'BEFORE',
            '  ┌───┬────────────────────────────────┐',
            '▋ │ A │ B                              │',
            '▋ ├───┼────────────────────────────────┤',
            '▋ │ x │ one two three four five six    │',
            '▋ │   │ seven eight nine ten           │',
            '  └───┴────────────────────────────────┘',
            'AFTER',
        })
    end)

    it('section indentation', function()
        util.setup.text({
            '# Section',
            '',
            '| A | B |',
            '| - | - |',
            '| x | one two three four five six seven eight nine ten |',
        }, {
            pipe_table = { cell = 'padded' },
            heading = { enabled = false },
            indent = { enabled = true, skip_level = 0, per_level = 2 },
        })
        util.assert_screen({
            '▎ # Section',
            '▎',
            '▎ ┌───┬────────────────────────────────┐',
            '▎ │ A │ B                              │',
            '▎ ├───┼────────────────────────────────┤',
            '▎ │ x │ one two three four five six    │',
            '▎ │   │ seven eight nine ten           │',
            '▎ └───┴────────────────────────────────┘',
        })
    end)

    it('viewport-dependent widths', function()
        local input = { '', '| A | B |', '| - | - |' }
        for _ = 1, 100 do
            input[#input + 1] = '| x | y |'
        end
        input[#input + 1] = '| x | ' .. ('long '):rep(40) .. '|'
        util.setup.text(input, {
            debounce = 0,
            pipe_table = { cell = 'trimmed' },
        })
        local expected = {
            '┌───┬───┐',
            '│ A │ B │',
            '├───┼───┤',
        }
        for _ = 1, 36 do
            expected[#expected + 1] = '│ x │ y │'
        end
        expected[#expected + 1] = ''
        util.assert_screen(expected)

        vim.api.nvim_win_set_cursor(0, { 100, 0 })
        vim.cmd('normal! zt')
        require('render-markdown').render({
            buf = vim.api.nvim_get_current_buf(),
        })
        vim.wait(0)
        util.assert_screen({
            '│ x │ y                                │',
            '│ x │ y                                │',
            '│ x │ y                                │',
            '│ x │ y                                │',
            '│ x │ long long long long long long    │',
            '│   │ long long long long long long    │',
            '│   │ long long long long long long    │',
            '│   │ long long long long long long    │',
            '│   │ long long long long long long    │',
            '│   │ long long long long long long    │',
            '│   │ long long long long              │',
            '└───┴──────────────────────────────────┘',
        })
    end)

    it('EOF', function()
        util.setup.text({
            '',
            '| A | B | C |',
            '| :- | :-: | -: |',
            '| x | y | short |',
            '| z | w | one two three four five six seven eight nine ten |',
        }, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen({
            '┌───┬───┬──────────────────────────────┐',
            '│ A │ B │                            C │',
            '├━──┼━─━┼─────────────────────────────━┤',
            '│ x │ y │                        short │',
            '│ z │ w │  one two three four five six │',
            '│   │   │         seven eight nine ten │',
            '└───┴───┴──────────────────────────────┘',
        })
    end)

    it('cursor on header at BOF', function()
        util.setup.text({
            '| Name | Description |',
            '| --- | --- |',
            '| **bold** | Here is a long description with [a link](https://example.com) and `some code` and 行行行. |',
            '| short | Another very long description which should wrap into several lines neatly. |',
        }, {
            anti_conceal = { enabled = true },
            pipe_table = { cell = 'trimmed' },
        })
        util.assert_screen({
            '| Name | Description |',
            '├───────┼──────────────────────────────┤',
            '│ bold  │ Here is a long description   │',
            '│       │ with 󰖟 a link and some code  │',
            '│       │ and 行行行.                  │',
            '│ short │ Another very long            │',
            '│       │ description which should     │',
            '│       │ wrap into several lines      │',
            '│       │ neatly.                      │',
            '└───────┴──────────────────────────────┘',
        })
    end)

    it('cursor on wrapped row', function()
        util.setup.text(mixed, { pipe_table = { cell = 'trimmed' } })
        util.assert_screen(mixed_rendered)

        vim.api.nvim_win_set_cursor(0, { 6, 0 })
        vim.cmd('doautocmd CursorMoved')
        vim.wait(0)
        util.assert_screen({
            'BEFORE',
            '┌───┬───┬──────────────────────────────┐',
            '│ A │ B │                            C │',
            '├━──┼━─━┼─────────────────────────────━┤',
            '│ x │ y │                        short │',
            '| z | w | one two three four five six se',
            'ven eight nine ten |',
            '│ a │ b │                          end │',
            '└───┴───┴──────────────────────────────┘',
            'AFTER',
        })

        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        vim.cmd('doautocmd CursorMoved')
        vim.wait(0)
        util.assert_screen(mixed_rendered)
    end)

    it('cursor on wrapped row with nowrap', function()
        vim.o.wrap = false
        util.setup.text(mixed, { pipe_table = { cell = 'trimmed' } })
        vim.api.nvim_win_set_cursor(0, { 6, 0 })
        vim.cmd('doautocmd CursorMoved')
        vim.wait(0)
        util.assert_screen({
            'BEFORE',
            '┌───┬───┬──────────────────────────────┐',
            '│ A │ B │                            C │',
            '├━──┼━─━┼─────────────────────────────━┤',
            '│ x │ y │                        short │',
            '| z | w | one two three four five six se',
            '│ a │ b │                          end │',
            '└───┴───┴──────────────────────────────┘',
            'AFTER',
        })
    end)

    it('edit', function()
        util.setup.text(mixed, {
            debounce = 0,
            pipe_table = { cell = 'trimmed' },
        })
        vim.api.nvim_buf_set_lines(0, 5, 6, false, {
            '| z | w | replacement words are long enough to wrap twice |',
        })
        vim.cmd('doautocmd TextChanged')
        vim.wait(0)
        util.assert_screen({
            'BEFORE',
            '┌───┬───┬──────────────────────────────┐',
            '│ A │ B │                            C │',
            '├━──┼━─━┼─────────────────────────────━┤',
            '│ x │ y │                        short │',
            '│ z │ w │   replacement words are long │',
            '│   │   │         enough to wrap twice │',
            '│ a │ b │                          end │',
            '└───┴───┴──────────────────────────────┘',
            'AFTER',
        })
    end)

    it('visual selection', function()
        util.setup.text(mixed, {
            anti_conceal = { enabled = true },
            pipe_table = { cell = 'trimmed' },
        })
        vim.api.nvim_win_set_cursor(0, { 3, 0 })
        vim.cmd('normal! V3j')
        vim.cmd('doautocmd CursorMoved')
        vim.wait(0)
        util.assert_screen({
            'BEFORE',
            '┌───┬───┬──────────────────────────────┐',
            '| A | B | C |',
            '| :- | :-: | -: |',
            '| x | y | short |',
            '| z | w | one two three four five six se',
            'ven eight nine ten |',
            '│ a │ b │                          end │',
            '└───┴───┴──────────────────────────────┘',
            'AFTER',
        })
    end)

    it('disable', function()
        vim.o.wrap = false
        util.setup.text(mixed, {
            debounce = 0,
            pipe_table = { cell = 'trimmed' },
        })
        require('render-markdown').disable()
        vim.wait(0)
        util.assert_screen({
            'BEFORE',
            '',
            '| A | B | C |',
            '| :- | :-: | -: |',
            '| x | y | short |',
            '| z | w | one two three four five six se',
            '| a | b | end |',
            '',
            'AFTER',
        })
    end)

    it('resize with line numbers', function()
        util.setup.text(mixed, {
            debounce = 0,
            pipe_table = { cell = 'trimmed' },
        })
        util.assert_screen(mixed_rendered)

        vim.o.columns = 55
        vim.o.number = true
        require('render-markdown').render({
            buf = vim.api.nvim_get_current_buf(),
        })
        vim.wait(0)
        util.assert_screen({
            '  1 BEFORE',
            '  2 ┌───┬───┬─────────────────────────────────────────┐',
            '  3 │ A │ B │                                       C │',
            '  4 ├━──┼━─━┼────────────────────────────────────────━┤',
            '  5 │ x │ y │                                   short │',
            '    │ z │ w │ one two three four five six seven eight │',
            '    │   │   │                                nine ten │',
            '  7 │ a │ b │                                     end │',
            '  8 └───┴───┴─────────────────────────────────────────┘',
            '  9 AFTER',
        })
    end)

    it('heading after table', function()
        util.setup.text({
            'BEFORE',
            '',
            '| A | B | C |',
            '| :- | :-: | -: |',
            '| x | y | short |',
            '| z | w | one two three four five six seven eight nine ten |',
            '# Heading',
        }, {
            pipe_table = { cell = 'trimmed' },
            heading = { border = true },
        })
        util.assert_screen({
            'BEFORE',
            '┌───┬───┬──────────────────────────────┐',
            '│ A │ B │                            C │',
            '├━──┼━─━┼─────────────────────────────━┤',
            '│ x │ y │                        short │',
            '│ z │ w │  one two three four five six │',
            '│   │   │         seven eight nine ten │',
            '└───┴───┴──────────────────────────────┘',
            '▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄',
            '󰲡 Heading',
            '▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀',
        })
    end)

    it('minimum widths cannot fit', function()
        vim.o.wrap = false
        util.setup.text({
            'BEFORE',
            '',
            '| A | B |',
            '| - | - |',
            '| x | y |',
            '',
            'AFTER',
        }, {
            pipe_table = { cell = 'trimmed', min_width = 20 },
        })
        util.assert_screen({
            'BEFORE',
            '┌────────────────────┬──────────────────',
            '│ A                  │ B',
            '├────────────────────┼──────────────────',
            '│ x                  │ y',
            '└────────────────────┴──────────────────',
            'AFTER',
        })
    end)

    it('raw cells', function()
        vim.o.wrap = false
        util.setup.text(mixed, { pipe_table = { cell = 'raw' } })
        util.assert_screen({
            'BEFORE',
            '',
            '│ A │ B │ C │',
            '├━───┼━───━┼────────────────────────────',
            '│ x │ y │ short │',
            '│ z │ w │ one two three four five six se',
            '│ a │ b │ end │',
            '',
            'AFTER',
        })
    end)

    it('conceallevel 1', function()
        vim.o.wrap = false
        util.setup.text(mixed, {
            pipe_table = { cell = 'trimmed' },
            win_options = { conceallevel = { rendered = 1 } },
        })
        util.assert_screen({
            'BEFORE',
            '┌───┬───┬───────────────────────────────',
            '│ A │ B │',
            '├━──┼━─━┼───────────────────────────────',
            '│ x │ y │',
            '│ z │ w │ one two three four five six se',
            '│ a │ b │',
            '└───┴───┴───────────────────────────────',
            'AFTER',
        })
    end)
end)
