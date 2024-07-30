---@module 'luassert'

local util = require('tests.util')
local eq = assert.are.same
local truthy = assert.truthy

---@param f fun()
---@return number
local function time(f)
    local start_ns = vim.uv.hrtime()
    f()
    return (vim.uv.hrtime() - start_ns) / 1e+6
end

---@param keys string
local function feed(keys)
    local escape = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(escape, 'nx', false)
end

describe('README.md', function()
    it('default', function()
        local start_time = time(function()
            util.setup('README.md')
        end)
        eq(442, #util.get_actual_marks())

        local move_time = time(function()
            feed('j')
            -- Unsure why, but the CursorMoved event needs to be triggered manually
            vim.api.nvim_exec_autocmds('CursorMoved', {})
            vim.wait(0)
        end)
        eq(444, #util.get_actual_marks())

        local refresh_time = time(function()
            feed('i')
            vim.wait(0)
        end)
        eq(444, #util.get_actual_marks())

        truthy(start_time > 25 and start_time < 75, 'expected start time (25, 75)')
        truthy(refresh_time > 20 and refresh_time < 40, 'expected refresh time (20, 40)')
        truthy(move_time > 0 and move_time < 1, 'expected move time (0, 1)')
    end)
end)
