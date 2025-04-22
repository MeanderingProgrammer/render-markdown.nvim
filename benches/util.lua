---@module 'luassert'

local Eq = assert.are.same
local True = assert.True

---@class render.md.bench.Util
local M = {}

---@param file string
---@return number
function M.setup(file)
    return M.time(function()
        require('render-markdown').setup({ debounce = 0 })
        vim.cmd('e ' .. file)
    end)
end

---@param n integer
---@return number
function M.move_down(n)
    return M.time(function()
        M.feed(string.format('%dj', n))
        -- Unsure why, but the CursorMoved event needs to be triggered manually
        vim.api.nvim_exec_autocmds('CursorMoved', {})
    end)
end

---@return number
function M.insert_mode()
    return M.time(function()
        M.feed('i')
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

---@private
---@param keys string
function M.feed(keys)
    local escape = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(escape, 'nx', false)
end

---@param actual number
---@param max number
function M.less_than(actual, max)
    True(actual < max, string.format('expected %f < %f', actual, max))
end

---@param expected integer
function M.num_marks(expected)
    local ui = require('render-markdown.core.ui')
    local marks = vim.api.nvim_buf_get_extmarks(0, ui.ns, 0, -1, {})
    Eq(expected, #marks)
end

return M
