---@module 'luassert'

local ui = require('render-markdown.ui')
local eq = assert.are.same
local truthy = assert.truthy

---@class render.md.bench.Util
local M = {}

---@param file string
---@param opts? render.md.UserConfig
---@return number
function M.setup(file, opts)
    return M.time(function()
        require('render-markdown').setup(opts)
        vim.cmd('e ' .. file)
        vim.wait(0)
    end)
end

---@param n integer
---@return number
function M.move_down(n)
    return M.time(function()
        M.feed(string.format('%dj', n))
        -- Unsure why, but the CursorMoved event needs to be triggered manually
        vim.api.nvim_exec_autocmds('CursorMoved', {})
        vim.wait(0)
    end)
end

---@return number
function M.insert_mode()
    return M.time(function()
        M.feed('i')
        vim.wait(0)
    end)
end

---@private
---@param f fun()
---@return number
function M.time(f)
    local start = vim.uv.hrtime()
    f()
    return (vim.uv.hrtime() - start) / 1e+6
end

---@private
---@param keys string
function M.feed(keys)
    local escape = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(escape, 'nx', false)
end

---@param low integer
---@param high integer
---@param actual number
function M.between(low, high, actual)
    truthy(actual > low and actual < high, string.format('expected %d < %f < %d', low, actual, high))
end

---@param expected integer
function M.num_marks(expected)
    local marks = vim.api.nvim_buf_get_extmarks(0, ui.namespace, 0, -1, {})
    eq(expected, #marks)
end

return M
