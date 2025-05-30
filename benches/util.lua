---@module 'luassert'

---@class render.md.bench.Util
local M = {}

---@param file string
---@return number
function M.setup(file)
    return M.time(function()
        require('render-markdown').setup({
            debounce = 0,
            change_events = { 'TextChanged' },
        })
        vim.cmd('e ' .. file)
    end)
end

---@param n integer
---@return number
function M.move_down(n)
    return M.time(function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_win_set_cursor(0, { row + n, col })
        -- CursorMoved event needs to be triggered manually
        vim.api.nvim_exec_autocmds('CursorMoved', {})
    end)
end

---@return number
function M.modify()
    return M.time(function()
        vim.api.nvim_exec_autocmds('TextChanged', {})
    end)
end

---@private
---@param callback fun()
---@return number
function M.time(callback)
    callback()
    local start_time = vim.uv.hrtime()
    vim.wait(0)
    local end_time = vim.uv.hrtime()
    return (end_time - start_time) / 1e+6
end

---@param actual number
---@param max number
function M.less_than(actual, max)
    assert.is_true(actual < max, ('expected %f < %f'):format(actual, max))
end

---@param expected integer
function M.num_marks(expected)
    local ui = require('render-markdown.core.ui')
    local marks = vim.api.nvim_buf_get_extmarks(0, ui.ns, 0, -1, {})
    assert.same(expected, #marks)
end

return M
