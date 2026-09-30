---@module 'luassert'

local util = require('tests.util')

describe('yank', function()
    local lines = {
        'Text',
        '```lua',
        'local a = 1',
        '',
        '  indented()',
        '```',
        '- item',
        '  ```c',
        '  int a;',
        '',
        '    int b;',
        '  ```',
        '> quote',
        '> ```',
        '> quoted',
        '>',
        '>   deeper',
        '> ```',
        '```',
        '```',
        '````md',
        '```lua',
        'nested()',
        '```',
        '````',
    }

    ---@param row integer
    ---@param register? string
    local function yank(row, register)
        vim.api.nvim_win_set_cursor(0, { row, 0 })
        require('render-markdown').yank_code(register)
    end

    ---@param register string
    ---@param expected string[]
    local function assert_register(register, expected)
        assert.same(expected, vim.fn.getreg(register, 1, true))
        assert.same('V', vim.fn.getregtype(register))
    end

    before_each(function()
        util.setup.text(lines)
        vim.fn.setreg('a', 'before')
    end)

    it('top level', function()
        yank(3, 'a')
        assert_register('a', { 'local a = 1', '', '  indented()' })
    end)

    it('fence', function()
        yank(2, 'a')
        assert_register('a', { 'local a = 1', '', '  indented()' })
    end)

    it('list', function()
        yank(11, 'a')
        assert_register('a', { 'int a;', '', '  int b;' })
    end)

    it('block quote', function()
        yank(15, 'a')
        assert_register('a', { 'quoted', '', '  deeper' })
    end)

    it('nested', function()
        yank(23, 'a')
        assert_register('a', { '```lua', 'nested()', '```' })
    end)

    it('empty', function()
        yank(19, 'a')
        assert.same('before', vim.fn.getreg('a'))
    end)

    it('outside', function()
        yank(1, 'a')
        assert.same('before', vim.fn.getreg('a'))
    end)

    it('default register', function()
        yank(9)
        assert_register('"', { 'int a;', '', '  int b;' })
    end)

    it('not attached', function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].filetype = 'text'
        yank(3, 'a')
        assert.same('before', vim.fn.getreg('a'))
    end)
end)
