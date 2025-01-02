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
    -- Window resizing is not buffer specific so is managed more globally
    vim.api.nvim_create_autocmd('WinResized', {
        group = M.group,
        callback = function(args)
            if not state.enabled then
                return
            end
            for _, win in ipairs(vim.v.event.windows) do
                local buf = vim.fn.winbufnr(win)
                if M.is_attached(buf) then
                    ui.update(buf, win, args.event, true)
                end
            end
        end,
    })
end

---@param enabled boolean
function M.set_all(enabled)
    -- Attempt to attach current buffer in case this is from a lazy load
    M.attach(util.current('buf'))
    state.enabled = enabled
    for _, buf in ipairs(buffers) do
        ui.update(buf, vim.fn.bufwinid(buf), 'UserCommand', true)
    end
end

---@param buf integer
---@return boolean
function M.is_attached(buf)
    return vim.tbl_contains(buffers, buf)
end

---@private
---@param buf integer
function M.attach(buf)
    if not M.should_attach(buf) then
        return
    end

    local config = state.get(buf)
    state.on.attach(buf)

    local events = { 'BufWinEnter', 'BufLeave', 'CmdlineChanged', 'CursorHold', 'CursorMoved', 'WinScrolled' }
    local change_events = { 'DiffUpdated', 'ModeChanged', 'TextChanged' }
    if config:render('i') then
        vim.list_extend(events, { 'CursorHoldI', 'CursorMovedI' })
        vim.list_extend(change_events, { 'TextChangedI' })
    end
    vim.api.nvim_create_autocmd(vim.list_extend(events, change_events), {
        group = M.group,
        buffer = buf,
        callback = function(args)
            if not state.enabled then
                return
            end
            local win, windows = util.current('win'), util.windows(buf)
            win = vim.tbl_contains(windows, win) and win or windows[1]
            if win == nil then
                return
            end
            local event = args.event
            ui.update(buf, win, event, vim.tbl_contains(change_events, event))
        end,
    })
end

---@private
---@param buf integer
---@return boolean
function M.should_attach(buf)
    log.buf('info', 'attach', buf, 'start')

    if M.is_attached(buf) then
        log.buf('info', 'attach', buf, 'skip', 'already attached')
        return false
    end

    local file_type, file_types = util.get('buf', buf, 'filetype'), state.file_types
    if not vim.tbl_contains(file_types, file_type) then
        local reason = string.format('%s /∈ %s', file_type, vim.inspect(file_types))
        log.buf('info', 'attach', buf, 'skip', 'file type', reason)
        return false
    end

    local config = state.get(buf)
    if not config.enabled then
        log.buf('info', 'attach', buf, 'skip', 'state disabled')
        return false
    end

    local file_size, max_file_size = util.file_size_mb(buf), config.max_file_size
    if file_size > max_file_size then
        local reason = string.format('%f > %f', file_size, max_file_size)
        log.buf('info', 'attach', buf, 'skip', 'file size', reason)
        return false
    end

    log.buf('info', 'attach', buf, 'success')
    table.insert(buffers, buf)
    return true
end

return M
