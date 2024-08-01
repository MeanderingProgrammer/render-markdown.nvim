---@class render.md.Util
local M = {}

---@type boolean
M.has_10 = vim.fn.has('nvim-0.10') == 1

---@param win integer
---@return integer
function M.win_to_buf(win)
    return vim.fn.winbufnr(win)
end

---@param buf integer
---@return integer
function M.buf_to_win(buf)
    return vim.fn.bufwinid(buf)
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
---@param value number|string
function M.set_win(win, name, value)
    vim.api.nvim_set_option_value(name, value, { scope = 'local', win = win })
end

---@param buf integer
---@param name string
---@return number|string
function M.get_buf(buf, name)
    return vim.api.nvim_get_option_value(name, { buf = buf })
end

---@param win integer
---@return integer
function M.get_leftcol(win)
    return vim.api.nvim_win_call(win, function()
        return vim.fn.winsaveview().leftcol
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
