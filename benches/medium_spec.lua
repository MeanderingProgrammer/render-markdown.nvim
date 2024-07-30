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

describe('medium.md', function()
    it('default', function()
        local start_time = time(function()
            util.setup('temp/medium.md')
        end)
        eq(2998, #util.get_actual_marks())

        local move_time = time(function()
            feed('3j')
            -- Unsure why, but the CursorMoved event needs to be triggered manually
            vim.api.nvim_exec_autocmds('CursorMoved', {})
            vim.wait(0)
        end)
        eq(3000, #util.get_actual_marks())

        local refresh_time = time(function()
            feed('i')
            vim.wait(0)
        end)
        eq(3000, #util.get_actual_marks())

        truthy(start_time > 25 and start_time < 75, 'expected start time (25, 75)')
        truthy(refresh_time > 25 and refresh_time < 50, 'expected refresh time (25, 50)')
        truthy(move_time > 1 and move_time < 5, 'expected move time (1, 5)')
    end)
end)
