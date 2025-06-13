local env = require('render-markdown.lib.env')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')
local ui = require('render-markdown.core.ui')

---@class render.md.manager.Config
---@field file_types string[]
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
    if #env.lazy('ft') == 0 and #env.lazy('cmd') == 0 then
        M.attach(env.buf.current())
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
            for _, win in ipairs(vim.v.event.windows) do
                local buf = env.win.buf(win)
                if M.attached(buf) and state.get(buf).enabled then
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
    if #env.lazy('cmd') > 0 then
        M.attach(env.buf.current())
    end
    if enabled ~= nil then
        state.enabled = enabled
    else
        state.enabled = not state.enabled
    end
    for _, buf in ipairs(M.buffers) do
        M.set_buf(buf, state.enabled)
    end
end

---@param buf? integer
---@param enabled? boolean
function M.set_buf(buf, enabled)
    buf = buf or env.buf.current()
    if M.attached(buf) then
        local config = state.get(buf)
        if enabled ~= nil then
            config.enabled = enabled
        else
            config.enabled = not config.enabled
        end
        ui.update(buf, env.buf.win(buf), 'UserCommand', true)
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
        require('render-markdown.integ.lsp').init()
    elseif M.config.completions.blink.enabled then
        require('render-markdown.integ.blink').init()
    elseif M.config.completions.coq.enabled then
        require('render-markdown.integ.coq').init()
    else
        require('render-markdown.integ.cmp').init()
    end

    local events = {
        'BufWinEnter',
        'BufLeave',
        'CmdlineChanged',
        'CursorHold',
        'CursorMoved',
        'DiffUpdated',
        'ModeChanged',
        'TextChanged',
        'WinScrolled',
    }
    if config.resolved:render('i') then
        events[#events + 1] = 'CursorHoldI'
        events[#events + 1] = 'CursorMovedI'
        events[#events + 1] = 'TextChangedI'
    end
    local force = M.config.change_events
    for _, event in ipairs(force) do
        if not vim.tbl_contains(events, event) then
            events[#events + 1] = event
        end
    end

    vim.api.nvim_create_autocmd(events, {
        group = M.group,
        buffer = buf,
        callback = function(args)
            if not state.get(buf).enabled then
                return
            end
            local win, wins = env.win.current(), env.buf.windows(buf)
            win = vim.tbl_contains(wins, win) and win or wins[1]
            if not win then
                return
            end
            local event = args.event
            ui.update(buf, win, event, vim.tbl_contains(force, event))
        end,
    })

    if config.enabled then
        ui.update(buf, env.buf.win(buf), 'Initial', true)
    end
end

---@private
---@param buf integer
---@return boolean
function M.should_attach(buf)
    log.attach(buf, 'start')

    if M.attached(buf) then
        log.attach(buf, 'skip', 'already attached')
        return false
    end

    if not vim.api.nvim_buf_is_valid(buf) then
        log.attach(buf, 'skip', 'invalid')
        return false
    end

    local file_type = env.buf.get(buf, 'filetype')
    local file_types = M.config.file_types
    if not vim.tbl_contains(file_types, file_type) then
        local reason = ('%s /∈ %s'):format(file_type, vim.inspect(file_types))
        log.attach(buf, 'skip', 'file type', reason)
        return false
    end

    local file_size = env.file_size_mb(buf)
    local max_file_size = state.get(buf).max_file_size
    if file_size > max_file_size then
        local reason = ('%f > %f'):format(file_size, max_file_size)
        log.attach(buf, 'skip', 'file size', reason)
        return false
    end

    if M.config.ignore(buf) then
        log.attach(buf, 'skip', 'user ignore')
        return false
    end

    log.attach(buf, 'success')
    M.buffers[#M.buffers + 1] = buf
    return true
end

return M
