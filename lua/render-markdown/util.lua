local M = {}

---@param win integer
---@return integer
M.win_to_buf = function(win)
    return vim.fn.winbufnr(win)
end

---@param buf integer
---@return integer
M.buf_to_win = function(buf)
    return vim.fn.bufwinid(buf)
end

---@param buf integer
---@param value integer
M.set_conceal = function(buf, value)
    local win = M.buf_to_win(buf)
    vim.api.nvim_set_option_value('conceallevel', value, { scope = 'local', win = win })
end

---@param buf integer
---@return number
M.file_size_mb = function(buf)
    local ok, stats = pcall(function()
        return vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
    end)
    if not (ok and stats) then
        return 0
    end
    return stats.size / (1024 * 1024)
end

return M
