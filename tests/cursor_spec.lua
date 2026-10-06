---@module 'luassert'

local util = require('tests.util')

describe('cursor', function()
    local lines = {
        'Text above',
        '```',
        'local value = 1',
        '```',
        'Text below the block',
        '',
        'Setext',
        '======',
        '',
        '```',
        'last',
        '```',
    }

    ---@param row integer
    ---@param col integer
    local function assert_cursor(row, col)
        assert.same({ row, col }, vim.api.nvim_win_get_cursor(0))
    end

    it('disabled', function()
        util.setup.text(lines)
        util.set_row(1)
        util.set_row(2)
        assert_cursor(2, 0)
    end)

    it('down', function()
        util.setup.text(lines, { cursor = { skip_hidden = true } })
        util.set_row(1)
        util.set_row(2)
        assert_cursor(3, 0)
        util.set_row(4)
        assert_cursor(5, 0)
        util.set_row(7)
        util.set_row(8)
        assert_cursor(9, 0)
    end)

    it('up', function()
        util.setup.text(lines, { cursor = { skip_hidden = true } })
        util.set_row(5)
        util.set_row(4)
        assert_cursor(3, 0)
        util.set_row(2)
        assert_cursor(1, 0)
    end)

    it('edge', function()
        util.setup.text(lines, { cursor = { skip_hidden = true } })
        util.set_row(11)
        util.set_row(12)
        assert_cursor(11, 0)
    end)

    it('column', function()
        util.setup.text(lines, { cursor = { skip_hidden = true } })
        util.set_row(3)
        vim.cmd('normal! $')
        vim.cmd('normal! j')
        vim.api.nvim_exec_autocmds('CursorMoved', {})
        assert_cursor(5, 19)
        vim.cmd('normal! k')
        vim.api.nvim_exec_autocmds('CursorMoved', {})
        assert_cursor(3, 14)
    end)

    it('fold', function()
        util.setup.text(lines, { cursor = { skip_hidden = true } })
        vim.cmd('1,3fold')
        util.set_row(5)
        util.set_row(4)
        assert_cursor(1, 0)
    end)

    it('anti conceal', function()
        util.setup.text(lines, {
            anti_conceal = { enabled = true },
            win_options = { concealcursor = { rendered = '' } },
            cursor = { skip_hidden = true },
        })
        util.set_row(1)
        util.set_row(2)
        assert_cursor(2, 0)
    end)
end)
