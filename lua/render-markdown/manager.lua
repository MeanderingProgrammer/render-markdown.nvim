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
    -- Lazy Loading: ignores current buffer as FileType event already executed
    if #util.lazy('ft') == 0 and #util.lazy('cmd') == 0 then
        M.attach(util.current('buf'))
    end
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

---@param buf integer
---@return boolean
function M.is_attached(buf)
    return vim.tbl_contains(buffers, buf)
end

---@param enabled? boolean
function M.set_all(enabled)
    -- Lazy Loading: all previously opened buffers have been ignored
    if #util.lazy('cmd') > 0 then
        M.attach(util.current('buf'))
    end
    if enabled ~= nil then
        state.enabled = enabled
    else
        state.enabled = not state.enabled
    end
    for _, buf in ipairs(buffers) do
        M.update(buf, 'UserCommand')
    end
end

---@param enabled? boolean
function M.set_current(enabled)
    local buf = util.current('buf')
    if M.is_attached(buf) then
        local config = state.get(buf)
        if enabled ~= nil then
            config.enabled = enabled
        else
            config.enabled = not config.enabled
        end
        M.update(buf, 'UserCommand')
    end
end

---@private
---@param buf integer
function M.attach(buf)
    if not M.should_attach(buf) then
        return
    end

    local config = state.get(buf)
    state.on.attach({ buf = buf })
    if state.completions.lsp.enabled then
        require('render-markdown.integ.lsp').setup()
    elseif state.completions.blink.enabled then
        require('render-markdown.integ.blink').setup()
    elseif state.completions.coq.enabled then
        require('render-markdown.integ.coq').setup()
    else
        require('render-markdown.integ.cmp').setup()
    end

    local events = { 'BufWinEnter', 'BufLeave', 'CmdlineChanged', 'CursorHold', 'CursorMoved', 'WinScrolled' }
    local change_events = { 'DiffUpdated', 'ModeChanged', 'TextChanged' }
    vim.list_extend(change_events, state.change_events)
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

    M.update(buf, 'Initial')
end

---@private
---@param buf integer
---@param event string
function M.update(buf, event)
    ui.update(buf, vim.fn.bufwinid(buf), event, true)
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

    if not vim.api.nvim_buf_is_valid(buf) then
        log.buf('info', 'attach', buf, 'skip', 'invalid')
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
