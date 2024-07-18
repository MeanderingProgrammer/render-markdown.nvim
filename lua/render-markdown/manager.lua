local state = require('render-markdown.state')
local ui = require('render-markdown.ui')
local util = require('render-markdown.util')

---@class render.md.manager.Data
---@field buffers integer[]

---@type render.md.manager.Data
local data = {
    buffers = {},
}

---@class render.md.Manager
local M = {}

---@private
---@type integer
M.group = vim.api.nvim_create_augroup('RenderMarkdown', { clear = true })

function M.setup()
    -- Attach to buffers based on matching filetype, this will add additional events
    vim.api.nvim_create_autocmd({ 'FileType' }, {
        group = M.group,
        pattern = state.config.file_types,
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
M.set_all = function(enabled)
    -- Attempt to attach current buffer in case this is from a lazy load
    M.attach(vim.api.nvim_get_current_buf())
    state.enabled = enabled
    for _, buf in ipairs(data.buffers) do
        ui.schedule_refresh(buf, true)
    end
end

---@private
---@param buf integer
M.attach = function(buf)
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
    vim.api.nvim_create_autocmd({ 'BufWinEnter', 'TextChanged' }, {
        group = M.group,
        buffer = buf,
        callback = function()
            ui.schedule_refresh(buf, true)
        end,
    })
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
                ui.schedule_refresh(buf, true)
            end
        end,
    })
    if state.config.anti_conceal.enabled then
        vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
            group = M.group,
            buffer = buf,
            callback = function()
                -- Moving cursor should not result in text change, skip parsing
                ui.schedule_refresh(buf, false)
            end,
        })
    end
end

return M
