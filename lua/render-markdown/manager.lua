local log = require('render-markdown.core.log')
local state = require('render-markdown.state')
local ui = require('render-markdown.core.ui')
local util = require('render-markdown.core.util')

---@type integer[]
local buffers = {}

---@class render.md.Manager
local M = {}

---@private
M.group = vim.api.nvim_create_augroup('RenderMarkdown', { clear = true })

---Should only be called from plugin directory
function M.setup()
    -- Attempt to attach to all buffers, cannot use pattern to support plugin directory
    vim.api.nvim_create_autocmd('FileType', {
        group = M.group,
        callback = function(args)
            M.attach(args.buf)
        end,
    })
    -- Window resizing is not buffer specific so is managed more globablly
    vim.api.nvim_create_autocmd('WinResized', {
        group = M.group,
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                local buf = vim.fn.winbufnr(win)
                if vim.tbl_contains(buffers, buf) then
                    ui.debounce_update(buf, win, true)
                end
            end
        end,
    })
    -- Write out any logs before closing
    vim.api.nvim_create_autocmd('VimLeave', {
        group = M.group,
        callback = log.flush,
    })
end

---@param enabled boolean
function M.set_all(enabled)
    -- Attempt to attach current buffer in case this is from a lazy load
    M.attach(vim.api.nvim_get_current_buf())
    state.enabled = enabled
    for _, buf in ipairs(buffers) do
        ui.debounce_update(buf, vim.fn.bufwinid(buf), true)
    end
end

---@private
---@param buf integer
function M.attach(buf)
    if not M.should_attach(buf) then
        return
    end
    local config = state.get_config(buf)
    local events = { 'BufWinEnter', 'BufLeave', 'CursorHold', 'CursorMoved' }
    local change_events = { 'ModeChanged', 'TextChanged' }
    if vim.tbl_contains(config.render_modes, 'i') then
        vim.list_extend(events, { 'CursorHoldI', 'CursorMovedI' })
        vim.list_extend(change_events, { 'TextChangedI' })
    end
    vim.api.nvim_create_autocmd(vim.list_extend(events, change_events), {
        group = M.group,
        buffer = buf,
        callback = function(args)
            local win = vim.api.nvim_get_current_win()
            if buf == vim.fn.winbufnr(win) then
                ui.debounce_update(buf, win, vim.tbl_contains(change_events, args.event))
            end
        end,
    })
end

---@private
---@param buf integer
---@return boolean
function M.should_attach(buf)
    local file = vim.api.nvim_buf_get_name(buf)
    local log_name = 'attach ' .. vim.fn.fnamemodify(file, ':t')
    log.debug(log_name, 'start')

    if vim.tbl_contains(buffers, buf) then
        log.debug(log_name, 'skip', 'already attached')
        return false
    end

    local file_type, file_types = util.get_buf(buf, 'filetype'), state.file_types
    if not vim.tbl_contains(file_types, file_type) then
        log.debug(log_name, 'skip', 'file type', string.format('%s /∈ %s', file_type, vim.inspect(file_types)))
        return false
    end

    local config = state.get_config(buf)
    if not config.enabled then
        log.debug(log_name, 'skip', 'state disabled')
        return false
    end

    local file_size, max_file_size = util.file_size_mb(file), config.max_file_size
    if file_size > max_file_size then
        log.debug(log_name, 'skip', 'file size', string.format('%f > %f', file_size, max_file_size))
        return false
    end

    log.debug(log_name, 'success')
    table.insert(buffers, buf)
    return true
end

return M
