---@module 'luassert'

local util = require('tests.util')

describe('viewport decoration performance', function()
    local function marks()
        local ui = require('render-markdown.core.ui')
        return vim.api.nvim_buf_get_extmarks(
            0,
            ui.ns,
            0,
            -1,
            { details = true }
        )
    end

    local function background(row)
        for _, mark in ipairs(marks()) do
            if mark[2] == row and mark[4].hl_eol then
                return true
            end
        end
        return false
    end

    ---@param opts? render.md.UserConfig
    local function code(opts)
        local lines = { '```text' }
        for i = 1, 500 do
            lines[#lines + 1] = 'line ' .. i
        end
        lines[#lines + 1] = '```'
        util.setup.text(
            lines,
            vim.tbl_deep_extend('force', {
                debounce = 0,
                code = { language = false },
            }, opts or {})
        )
    end

    after_each(function()
        vim.cmd('only!')
    end)

    it(
        'bounds code backgrounds while rendering newly visible rows after scrolling',
        function()
            code()
            assert.is_true(background(10))
            assert.is_true(#marks() < 150)
            util.set_row(250, true)
            assert.is_true(background(250))
            assert.is_true(#marks() < 150)
        end
    )

    it('renders the combined visible ranges of multiple windows', function()
        code()
        vim.cmd('vsplit')
        util.set_row(350, true)
        vim.api.nvim_exec_autocmds('TextChanged', {})
        vim.wait(0)
        assert.is_true(background(10))
        assert.is_true(background(350))
        assert.is_true(#marks() < 250)
    end)

    it('refreshes code decorations when an inactive split scrolls', function()
        code({ code = { width = 'block', left_pad = 2, right_pad = 3 } })
        local inactive = vim.api.nvim_get_current_win()
        vim.cmd('vsplit')
        vim.wait(0)
        local active = vim.api.nvim_get_current_win()
        assert.is_true(background(10))
        assert.is_false(background(349))

        vim.api.nvim_win_set_cursor(inactive, { 350, 0 })
        vim.api.nvim_exec_autocmds('WinScrolled', {})
        vim.wait(0)

        assert.same(active, vim.api.nvim_get_current_win())
        assert.is_true(background(10))
        assert.is_true(background(349))
        local padded = false
        for _, mark in ipairs(marks()) do
            if mark[2] == 349 and mark[4].virt_text_pos == 'inline' then
                padded = true
            end
        end
        assert.is_true(padded)
        assert.is_false(background(200))
        assert.is_true(#marks() < 750)
    end)

    it(
        'reuses decorations when an inactive split stays within cached ranges',
        function()
            code()
            local inactive = vim.api.nvim_get_current_win()
            vim.cmd('vsplit')
            vim.wait(0)
            local before = marks()

            vim.api.nvim_win_set_cursor(inactive, { 6, 0 })
            vim.api.nvim_win_call(inactive, function()
                vim.fn.winrestview({ topline = 6 })
            end)
            vim.api.nvim_exec_autocmds('WinScrolled', {})
            vim.wait(0)

            assert.same(before, marks())
        end
    )

    it('bounds section indentation to visible rows', function()
        local lines = { '## Section' }
        for i = 1, 500 do
            lines[#lines + 1] = 'line ' .. i
        end
        util.setup.text(lines, { debounce = 0, indent = { enabled = true } })
        assert.is_true(#marks() < 150)
        util.set_row(250, true)
        local found = false
        for _, mark in ipairs(marks()) do
            if mark[2] == 250 and mark[4].virt_text then
                found = true
            end
        end
        assert.is_true(found)
        assert.is_true(#marks() < 150)
    end)

    it(
        'refreshes section indentation when an inactive split scrolls',
        function()
            local lines = { '## Section' }
            for i = 1, 500 do
                lines[#lines + 1] = 'line ' .. i
            end
            util.setup.text(
                lines,
                { debounce = 0, indent = { enabled = true } }
            )
            local inactive = vim.api.nvim_get_current_win()
            vim.cmd('vsplit')
            vim.wait(0)
            local active = vim.api.nvim_get_current_win()

            vim.api.nvim_win_set_cursor(inactive, { 350, 0 })
            vim.api.nvim_exec_autocmds('WinScrolled', {})
            vim.wait(0)

            assert.same(active, vim.api.nvim_get_current_win())
            local found = false
            for _, mark in ipairs(marks()) do
                if mark[2] == 349 and mark[4].virt_text then
                    found = true
                end
            end
            assert.is_true(found)
            assert.is_true(#marks() < 250)
        end
    )

    it(
        'retains whole-block width while bounding padding to viewport rows',
        function()
            local lines = { '```', 'short' }
            for _ = 1, 498 do
                lines[#lines + 1] = 'small'
            end
            lines[#lines + 1] = ('W'):rep(60)
            lines[#lines + 1] = '```'
            util.setup.text(lines, {
                debounce = 0,
                code = { width = 'block', left_pad = 2, right_pad = 3 },
            })
            local padding_col
            for _, mark in ipairs(marks()) do
                if mark[2] == 10 and mark[4].virt_text_win_col then
                    padding_col = mark[4].virt_text_win_col
                end
            end
            assert.same(65, padding_col)
            assert.is_true(#marks() < 200)
        end
    )
end)
