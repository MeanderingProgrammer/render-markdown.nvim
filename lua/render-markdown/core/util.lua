---@class render.md.Util
local M = {}

M.has_10 = vim.fn.has('nvim-0.10') == 1

---@param name string
---@return string[]
function M.lazy_file_types(name)
    -- https://github.com/folke/lazydev.nvim/blob/main/lua/lazydev/pkg.lua -> get_plugin_path
    if type(package.loaded.lazy) ~= 'table' then
        return {}
    end
    local ok, lazy_config = pcall(require, 'lazy.core.config')
    if not ok then
        return {}
    end
    local plugin = lazy_config.spec.plugins[name]
    if plugin == nil then
        return {}
    end
    local file_types = plugin.ft
    if type(file_types) == 'table' then
        return file_types
    elseif type(file_types) == 'string' then
        return { file_types }
    else
        return {}
    end
end

---@param buf integer
---@param win integer
---@return boolean
function M.valid(buf, win)
    if buf == nil or not vim.api.nvim_buf_is_valid(buf) then
        return false
    end
    if win == nil or not vim.api.nvim_win_is_valid(win) then
        return false
    end
    return buf == vim.fn.winbufnr(win)
end

---@return string
function M.mode()
    return vim.fn.mode(true)
end

---@param buf integer
---@return integer[]
function M.windows(buf)
    return vim.fn.win_findbuf(buf)
end

---@param buf integer
---@param win integer
---@return integer?
function M.row(buf, win)
    if M.current('buf') ~= buf then
        return nil
    end
    return vim.api.nvim_win_get_cursor(win)[1] - 1
end

---@param variant 'buf'|'win'
---@return integer
function M.current(variant)
    if variant == 'buf' then
        return vim.api.nvim_get_current_buf()
    else
        return vim.api.nvim_get_current_win()
    end
end

---@param variant 'buf'|'win'
---@param id integer
---@param name string
---@return render.md.option.Value
---@overload fun(variant: 'buf', id: integer, name: 'buftype'): string
---@overload fun(variant: 'buf', id: integer, name: 'filetype'): string
---@overload fun(variant: 'buf', id: integer, name: 'tabstop'): integer
---@overload fun(variant: 'win', id: integer, name: 'conceallevel'): integer
---@overload fun(variant: 'win', id: integer, name: 'diff'): boolean
function M.get(variant, id, name)
    if variant == 'buf' then
        return vim.api.nvim_get_option_value(name, { buf = id })
    else
        return vim.api.nvim_get_option_value(name, { scope = 'local', win = id })
    end
end

---@param variant 'buf'|'win'
---@param id integer
---@param name string
---@param value render.md.option.Value
function M.set(variant, id, name, value)
    if value ~= M.get(variant, id, name) then
        if variant == 'buf' then
            vim.api.nvim_set_option_value(name, value, { buf = id })
        else
            vim.api.nvim_set_option_value(name, value, { scope = 'local', win = id })
        end
    end
end

---@param win integer
---@return vim.fn.winsaveview.ret
function M.view(win)
    return vim.api.nvim_win_call(win, vim.fn.winsaveview)
end

---@param win integer
---@param row integer
---@return boolean
function M.row_visible(win, row)
    return vim.api.nvim_win_call(win, function()
        return vim.fn.foldclosed(row) == -1
    end)
end

---@param win integer
---@return integer
function M.textoff(win)
    local infos = vim.fn.getwininfo(win)
    return #infos == 1 and infos[1].textoff or 0
end

---@param buf integer
---@return string
function M.file_name(buf)
    local file = vim.api.nvim_buf_get_name(buf)
    return vim.fn.fnamemodify(file, ':t')
end

---@param source string|integer
---@return number
function M.file_size_mb(source)
    local file = source
    if type(file) == 'number' then
        file = vim.api.nvim_buf_get_name(file)
    end
    local ok, stats = pcall(function()
        return (vim.uv or vim.loop).fs_stat(file)
    end)
    if not (ok and stats) then
        return 0
    end
    return stats.size / (1024 * 1024)
end

---@param callback fun()
---@return fun()
function M.wrap_runtime(callback)
    return function()
        local start_time = (vim.uv or vim.loop).hrtime()
        callback()
        local end_time = (vim.uv or vim.loop).hrtime()
        vim.print(string.format('Runtime (ms): %.1f', (end_time - start_time) / 1e+6))
    end
end

return M
