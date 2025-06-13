local compat = require('render-markdown.lib.compat')

---@class render.md.Env
local M = {}

---@param key 'ft'|'cmd'
---@return string[]
function M.lazy(key)
    -- https://github.com/folke/lazydev.nvim/blob/main/lua/lazydev/pkg.lua -> get_plugin_path
    if type(package.loaded.lazy) ~= 'table' then
        return {}
    end
    local config_ok, lazy_config = pcall(require, 'lazy.core.config')
    local plugin_ok, lazy_plugin = pcall(require, 'lazy.core.plugin')
    if not config_ok or not plugin_ok then
        return {}
    end
    local name = 'render-markdown.nvim'
    local plugin = lazy_config.spec.plugins[name]
    if not plugin then
        return {}
    end
    local ok, values = pcall(lazy_plugin.values, plugin, key, true)
    return ok and values or {}
end

---@param file string|integer
---@return number
function M.file_size_mb(file)
    if type(file) ~= 'string' then
        file = vim.api.nvim_buf_get_name(file)
    end
    local ok, stats = pcall(function()
        return compat.uv.fs_stat(file)
    end)
    if not ok or not stats then
        return 0
    end
    return stats.size / (1024 * 1024)
end

---@param buf integer
---@param win integer
---@return boolean
function M.valid(buf, win)
    if not M.buf.valid(buf) or not M.win.valid(win) then
        return false
    end
    return buf == M.win.buf(win)
end

---@param buf integer
---@param win integer
---@param offset integer
---@return integer, integer
function M.range(buf, win, offset)
    local top = math.max(M.win.view(win).topline - 1 - offset, 0)
    local bottom = top
    local lines = vim.api.nvim_buf_line_count(buf)
    local size = vim.api.nvim_win_get_height(win) + (2 * offset)
    while bottom < lines and size > 0 do
        bottom = bottom + 1
        if M.row.visible(win, bottom) then
            size = size - 1
        end
    end
    return top, bottom
end

---@class render.md.env.Row
M.row = {}

---@param buf integer
---@param win integer
---@return integer?
function M.row.get(buf, win)
    if buf ~= M.buf.current() then
        return nil
    end
    return vim.api.nvim_win_get_cursor(win)[1] - 1
end

---@param win integer
---@param row integer
---@return boolean
function M.row.visible(win, row)
    return vim.api.nvim_win_call(win, function()
        return vim.fn.foldclosed(row) == -1
    end)
end

---@class render.md.env.Mode
M.mode = {}

---@return string
function M.mode.get()
    return vim.fn.mode(true)
end

---@param mode string
---@param modes render.md.Modes
---@return boolean
function M.mode.is(mode, modes)
    if type(modes) == 'boolean' then
        return modes
    else
        return vim.tbl_contains(modes, mode)
    end
end

---@class render.md.env.Buf
M.buf = {}

---@return integer
function M.buf.current()
    return vim.api.nvim_get_current_buf()
end

---@param buf integer
---@return boolean
function M.buf.valid(buf)
    return vim.api.nvim_buf_is_valid(buf)
end

---@param buf integer
---@param name string
---@return render.md.option.Value
---@overload fun(buf: integer, name: 'buflisted'): boolean
---@overload fun(buf: integer, name: 'buftype'): string
---@overload fun(buf: integer, name: 'filetype'): string
---@overload fun(buf: integer, name: 'tabstop'): integer
function M.buf.get(buf, name)
    return vim.api.nvim_get_option_value(name, { buf = buf })
end

---@param buf integer
---@param name string
---@param value render.md.option.Value
function M.buf.set(buf, name, value)
    if value ~= M.buf.get(buf, name) then
        vim.api.nvim_set_option_value(name, value, { buf = buf })
    end
end

---@param buf integer
---@return boolean
function M.buf.empty(buf)
    if vim.api.nvim_buf_line_count(buf) > 1 then
        return false
    else
        local line = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]
        return not line or line == ''
    end
end

---@param buf integer
---@return integer
function M.buf.win(buf)
    return vim.fn.bufwinid(buf)
end

---@param buf integer
---@return integer[]
function M.buf.windows(buf)
    return vim.fn.win_findbuf(buf)
end

---@class render.md.env.Win
M.win = {}

---@return integer
function M.win.current()
    return vim.api.nvim_get_current_win()
end

---@param win integer
---@return boolean
function M.win.valid(win)
    return vim.api.nvim_win_is_valid(win)
end

---@param win integer
---@param name string
---@return render.md.option.Value
---@overload fun(win: integer, name: 'conceallevel'): integer
---@overload fun(win: integer, name: 'diff'): boolean
function M.win.get(win, name)
    return vim.api.nvim_get_option_value(name, { scope = 'local', win = win })
end

---@param win integer
---@param name string
---@param value render.md.option.Value
function M.win.set(win, name, value)
    if value ~= M.win.get(win, name) then
        vim.api.nvim_set_option_value(name, value, {
            scope = 'local',
            win = win,
        })
    end
end

---@param win integer
---@return integer
function M.win.buf(win)
    return vim.fn.winbufnr(win)
end

---@param win integer
---@return vim.fn.winsaveview.ret
function M.win.view(win)
    return vim.api.nvim_win_call(win, vim.fn.winsaveview)
end

---@param win integer
---@param value number
---@param used integer
---@return integer
function M.win.percent(win, value, used)
    if value <= 0 then
        return 0
    elseif value >= 1 then
        return value
    else
        local infos = vim.fn.getwininfo(win)
        local textoff = #infos == 1 and infos[1].textoff or 0
        local width = vim.api.nvim_win_get_width(win) - textoff - used
        return math.floor((width * value) + 0.5)
    end
end

return M
