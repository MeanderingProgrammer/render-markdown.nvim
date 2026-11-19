---@module 'luassert'

local util = require('tests.util')

describe('debounce', function()
    it('renders final state', function()
        local lines = {} ---@type string[]
        for i = 1, 200 do
            lines[i] = '# Heading ' .. i
        end
        util.setup.text(lines, { debounce = 100 })

        ---@param keys string
        local function scroll(keys)
            vim.cmd('normal! ' .. keys)
            vim.api.nvim_exec_autocmds('CursorMoved', { buffer = 0 })
            vim.wait(0)
        end

        ---@param row integer
        ---@return boolean
        local function rendered(row)
            local ns = require('render-markdown.core.ui').ns
            local start, stop = { row - 1, 0 }, { row - 1, -1 }
            return #vim.api.nvim_buf_get_extmarks(0, ns, start, stop, {}) > 0
        end

        -- first scroll renders immediately
        scroll('100Gzt')
        assert.is_true(rendered(100))

        -- second scroll is queued until debounce ends
        scroll('G')
        assert.is_false(rendered(200))
        vim.wait(1000, function()
            return rendered(200)
        end)
        assert.is_true(rendered(200))
    end)
end)
