local env = require('render-markdown.lib.env')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')
local ui = require('render-markdown.core.ui')

---@class render.md.Manager
local M = {}

---@private
M.group = vim.api.nvim_create_augroup('RenderMarkdown', {})

---@private
---@type integer[]
M.buffers = {}

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
            for _, win in ipairs(vim.v.event.windows or {}) do
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

---@param enable? boolean
function M.set(enable)
    -- lazy loading: all previously opened buffers have been ignored
    if #env.lazy('cmd') > 0 then
        M.attach(env.buf.current())
    end
    if enable ~= nil then
        state.enabled = enable
    else
        state.enabled = not state.enabled
    end
    for _, buf in ipairs(M.buffers) do
        M.set_buf(buf, state.enabled)
    end
end

---@param buf? integer
---@param enable? boolean
function M.set_buf(buf, enable)
    buf = buf or env.buf.current()
    if M.attached(buf) then
        local config = state.get(buf)
        if enable ~= nil then
            config.enabled = enable
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
    state.on.attach({ buf = buf })
    require('render-markdown.core.ts').init()
    if state.completions.lsp.enabled then
        require('render-markdown.integ.lsp').init()
    elseif state.completions.blink.enabled then
        require('render-markdown.integ.blink').init()
    elseif state.completions.coq.enabled then
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
    local force = state.change_events
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
            local win = env.buf.win(buf)
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
    local file_types = state.file_types
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

    if state.ignore(buf) then
        log.attach(buf, 'skip', 'user ignore')
        return false
    end

    log.attach(buf, 'success')
    M.buffers[#M.buffers + 1] = buf
    return true
end

return M
