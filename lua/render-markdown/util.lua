local logger = require('render-markdown.logger')

---@class render.md.Util
local M = {}

---@type boolean
M.has_10 = vim.fn.has('nvim-0.10') == 1

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

---@param win integer
---@param name string
---@return any
M.get_win_option = function(win, name)
    return vim.api.nvim_get_option_value(name, { scope = 'local', win = win })
end

---@param win integer
---@param name string
---@param value any
M.set_win_option = function(win, name, value)
    local before = M.get_win_option(win, name)
    vim.api.nvim_set_option_value(name, value, { scope = 'local', win = win })
    logger.debug({ option = name, win = win, before = before, after = value })
end

---@param win integer
---@return integer
M.get_leftcol = function(win)
    return vim.api.nvim_win_call(win, function()
        return vim.fn.winsaveview().leftcol
    end)
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
