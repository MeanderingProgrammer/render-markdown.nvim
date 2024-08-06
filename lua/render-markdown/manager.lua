local state = require('render-markdown.state')
local ui = require('render-markdown.ui')
local util = require('render-markdown.util')

---@type integer[]
local buffers = {}

---@class render.md.Manager
local M = {}

---@private
---@type integer
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
    if not vim.tbl_contains(state.file_types, util.get_buf(buf, 'filetype')) then
        return
    end
    local config = state.get_config(buf)
    if not config.enabled then
        return
    end
    if util.file_size_mb(buf) > config.max_file_size then
        return
    end
    if vim.tbl_contains(buffers, buf) then
        return
    end
    table.insert(buffers, buf)

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

return M
