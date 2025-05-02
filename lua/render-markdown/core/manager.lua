local Env = require('render-markdown.lib.env')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')
local ui = require('render-markdown.core.ui')

---@class render.md.manager.Config
---@field ignore fun(buf: integer): boolean
---@field change_events string[]
---@field on render.md.on.Config
---@field completions render.md.completions.Config

---@class render.md.Manager
---@field private config render.md.manager.Config
local M = {}

---@private
M.group = vim.api.nvim_create_augroup('RenderMarkdown', {})

---@private
---@type integer[]
M.buffers = {}

---called from state on setup
---@param config render.md.manager.Config
function M.setup(config)
    M.config = config
end

---called from plugin directory
function M.init()
    -- lazy loading: ignores current buffer as FileType event already executed
    if #Env.lazy('ft') == 0 and #Env.lazy('cmd') == 0 then
        M.attach(Env.buf.current())
    end
    -- attempt to attach to all buffers, cannot use pattern to support plugin directory
    vim.api.nvim_create_autocmd('FileType', {
        group = M.group,
        callback = function(args)
            M.attach(args.buf)
        end,
    })
    -- window resizing is not buffer specific so is managed more globally
    vim.api.nvim_create_autocmd('WinResized', {
        group = M.group,
        callback = function(args)
            if not state.enabled then
                return
            end
            for _, win in ipairs(vim.v.event.windows) do
                local buf = Env.win.buf(win)
                if M.attached(buf) then
                    ui.update(buf, win, args.event, true)
                end
            end
        end,
    })
end

---@param buf integer
---@return boolean
function M.attached(buf)
    return vim.tbl_contains(M.buffers, buf)
end

---@param enabled? boolean
function M.set_all(enabled)
    -- lazy loading: all previously opened buffers have been ignored
    if #Env.lazy('cmd') > 0 then
        M.attach(Env.buf.current())
    end
    if enabled ~= nil then
        state.enabled = enabled
    else
        state.enabled = not state.enabled
    end
    for _, buf in ipairs(M.buffers) do
        M.update(buf, 'UserCommand')
    end
end

---@param enabled? boolean
function M.set_current(enabled)
    local buf = Env.buf.current()
    if M.attached(buf) then
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
    M.config.on.attach({ buf = buf })
    require('render-markdown.core.ts').init()
    if M.config.completions.lsp.enabled then
        require('render-markdown.integ.lsp').setup()
    elseif M.config.completions.blink.enabled then
        require('render-markdown.integ.blink').setup()
    elseif M.config.completions.coq.enabled then
        require('render-markdown.integ.coq').setup()
    else
        require('render-markdown.integ.cmp').setup()
    end

    local events = {
        'BufWinEnter',
        'BufLeave',
        'CmdlineChanged',
        'CursorHold',
        'CursorMoved',
        'WinScrolled',
    }
    local change_events = { 'DiffUpdated', 'ModeChanged', 'TextChanged' }
    vim.list_extend(change_events, M.config.change_events)
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
            local win, windows = Env.win.current(), Env.buf.windows(buf)
            win = vim.tbl_contains(windows, win) and win or windows[1]
            if not win then
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
    ui.update(buf, Env.buf.win(buf), event, true)
end

---@private
---@param buf integer
---@return boolean
function M.should_attach(buf)
    log.buf('info', 'attach', buf, 'start')

    if M.attached(buf) then
        log.buf('info', 'attach', buf, 'skip', 'already attached')
        return false
    end

    if not vim.api.nvim_buf_is_valid(buf) then
        log.buf('info', 'attach', buf, 'skip', 'invalid')
        return false
    end

    local file_type, file_types = Env.buf.get(buf, 'filetype'), state.file_types
    if not vim.tbl_contains(file_types, file_type) then
        local reason = file_type .. ' /∈ ' .. vim.inspect(file_types)
        log.buf('info', 'attach', buf, 'skip', 'file type', reason)
        return false
    end

    local config = state.get(buf)
    if not config.enabled then
        log.buf('info', 'attach', buf, 'skip', 'state disabled')
        return false
    end

    local file_size, max_file_size = Env.file_size_mb(buf), config.max_file_size
    if file_size > max_file_size then
        local reason = ('%f > %f'):format(file_size, max_file_size)
        log.buf('info', 'attach', buf, 'skip', 'file size', reason)
        return false
    end

    if M.config.ignore(buf) then
        log.buf('info', 'attach', buf, 'skip', 'user ignore')
        return false
    end

    log.buf('info', 'attach', buf, 'success')
    M.buffers[#M.buffers + 1] = buf
    return true
end

return M
