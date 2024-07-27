local state = require('render-markdown.state')
local ui = require('render-markdown.ui')
local util = require('render-markdown.util')

---@class render.md.manager.Data
local data = {
    ---@type integer[]
    buffers = {},
}

---@class render.md.Manager
local M = {}

---@private
---@type integer
M.group = vim.api.nvim_create_augroup('RenderMarkdown', { clear = true })

---Should only be called from plugin directory
function M.setup()
    -- Attempt to attach to all buffers, cannot use pattern to support plugin directory
    vim.api.nvim_create_autocmd({ 'FileType' }, {
        group = M.group,
        callback = function(event)
            M.attach(event.buf)
        end,
    })
    -- Window resizing is not buffer specific so is managed more globablly
    vim.api.nvim_create_autocmd({ 'WinResized' }, {
        group = M.group,
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                local buf = util.win_to_buf(win)
                if vim.tbl_contains(data.buffers, buf) then
                    ui.schedule_refresh(buf, true)
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
    for _, buf in ipairs(data.buffers) do
        ui.schedule_refresh(buf, true)
    end
end

---@private
---@param buf integer
function M.attach(buf)
    if not vim.tbl_contains(state.config.file_types, util.get_buf(buf, 'filetype')) then
        return
    end
    if vim.tbl_contains(state.config.exclude.buftypes, util.get_buf(buf, 'buftype')) then
        return
    end
    if vim.tbl_contains(data.buffers, buf) then
        return
    end
    table.insert(data.buffers, buf)
    -- Events that do not imply modifications to buffer so can avoid re-parsing
    -- This relies on the ui parsing the buffer anyway if it is the first refresh
    vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufLeave' }, {
        group = M.group,
        buffer = buf,
        callback = function()
            ui.schedule_refresh(buf, false)
        end,
    })
    -- Events that imply modifications to buffer so require re-parsing
    vim.api.nvim_create_autocmd({ 'TextChanged' }, {
        group = M.group,
        buffer = buf,
        callback = function()
            ui.schedule_refresh(buf, true)
        end,
    })
    -- Use information specific to this event to determine whether to render or not
    vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
        group = M.group,
        buffer = buf,
        callback = function()
            local render_modes = state.config.render_modes
            local prev_rendered = vim.tbl_contains(render_modes, vim.v.event.old_mode)
            local should_render = vim.tbl_contains(render_modes, vim.v.event.new_mode)
            -- Only need to re-render if render state is changing. I.e. going from normal mode to
            -- command mode with the default config, both are rendered, so no point re-rendering
            if prev_rendered ~= should_render then
                -- Since we do not listen to changes that happen while the user is in insert mode
                -- we must assume changes were made and re-parse the buffer
                ui.schedule_refresh(buf, true)
            end
        end,
    })
    if state.config.anti_conceal.enabled then
        vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
            group = M.group,
            buffer = buf,
            callback = function()
                -- Moving cursor should not result in modifications to buffer so can avoid re-parsing
                ui.schedule_refresh(buf, false)
            end,
        })
    end
end

return M
