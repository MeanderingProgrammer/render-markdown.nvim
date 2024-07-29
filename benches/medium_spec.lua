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

        truthy(start_time > 400 and start_time < 500, 'expected start time (400, 500)')
        truthy(refresh_time > 400 and refresh_time < 500, 'expected refresh time (400, 500)')
        truthy(move_time > 1 and move_time < 5, 'expected move time (1, 5)')
    end)
end)
