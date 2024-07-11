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

function M.setup()
    local group = vim.api.nvim_create_augroup('RenderMarkdown', { clear = true })
    -- Attach to buffers based on matching filetype, this will add additional events
    vim.api.nvim_create_autocmd({ 'FileType' }, {
        group = group,
        pattern = state.config.file_types,
        callback = function(event)
            local buftype = vim.api.nvim_get_option_value('buftype', { buf = event.buf })
            if not vim.tbl_contains(state.config.exclude.buftypes, buftype) then
                M.attach(group, event.buf)
            end
        end,
    })
    -- Window resizing is not buffer specific so is managed more globablly
    vim.api.nvim_create_autocmd({ 'WinResized' }, {
        group = group,
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                local buf = util.win_to_buf(win)
                if vim.tbl_contains(data.buffers, buf) then
                    ui.schedule_refresh(buf)
                end
            end
        end,
    })
end

---@private
---@param group integer
---@param buf integer
M.attach = function(group, buf)
    if not vim.tbl_contains(data.buffers, buf) then
        table.insert(data.buffers, buf)
    end
    vim.api.nvim_create_autocmd({ 'BufWinEnter', 'TextChanged' }, {
        group = group,
        buffer = buf,
        callback = function()
            ui.schedule_refresh(buf)
        end,
    })
    vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
        group = group,
        buffer = buf,
        callback = function()
            local render_modes = state.config.render_modes
            local prev_rendered = vim.tbl_contains(render_modes, vim.v.event.old_mode)
            local should_render = vim.tbl_contains(render_modes, vim.v.event.new_mode)
            -- Only need to re-render if render state is changing. I.e. going from normal mode to
            -- command mode with the default config, both are rendered, so no point re-rendering
            if prev_rendered ~= should_render then
                ui.schedule_refresh(buf)
            end
        end,
    })
end

M.toggle = function()
    state.enabled = not state.enabled
    for _, buf in ipairs(data.buffers) do
        ui.schedule_refresh(buf)
    end
end

return M
