---@class render.md.Util
local M = {}

---@type boolean
M.has_10 = vim.fn.has('nvim-0.10') == 1

---@param buf integer
---@param win integer
---@return boolean
function M.valid(buf, win)
    return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_is_valid(win)
end

---@param buf integer
---@param win integer
---@return integer?
function M.cursor_row(buf, win)
    if vim.api.nvim_get_current_buf() ~= buf then
        return nil
    end
    return vim.api.nvim_win_get_cursor(win)[1] - 1
end

---@param win integer
---@param name string
---@return number|string|boolean
function M.get_win(win, name)
    return vim.api.nvim_get_option_value(name, { scope = 'local', win = win })
end

---@param win integer
---@param name string
---@param value number|string|boolean
function M.set_win(win, name, value)
    vim.api.nvim_set_option_value(name, value, { scope = 'local', win = win })
end

---@param buf integer
---@param name string
---@return number|string|boolean
function M.get_buf(buf, name)
    return vim.api.nvim_get_option_value(name, { buf = buf })
end

---@param win integer
---@return vim.fn.winsaveview.ret
function M.view(win)
    return vim.api.nvim_win_call(win, vim.fn.winsaveview)
end

---@param win integer
---@param row integer
---@return boolean
function M.visible(win, row)
    return vim.api.nvim_win_call(win, function()
        return vim.fn.foldclosed(row) == -1
    end)
end

---@param buf integer
---@return number
function M.file_size_mb(buf)
    local ok, stats = pcall(function()
        return vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
    end)
    if not (ok and stats) then
        return 0
    end
    return stats.size / (1024 * 1024)
end

return M
