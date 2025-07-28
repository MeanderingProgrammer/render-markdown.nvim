---@class render.md.Compat
local M = {}

M.uv = vim.uv or vim.loop
M.has_10 = vim.fn.has('nvim-0.10') == 1
M.has_11 = vim.fn.has('nvim-0.11') == 1

---@param buf integer
---@param win integer
---@param extmarks render.md.Extmark[]
---@see vim.lsp.util.open_floating_preview
function M.fix_lsp_window(buf, win, extmarks)
    -- this is a fragile way of identifying whether this is a floating LSP
    -- window, comes from the implementation and not from any documentation
    local has_lsp = pcall(vim.api.nvim_win_get_var, win, 'lsp_floating_bufnr')
    if not has_lsp then
        return
    end

    local env = require('render-markdown.lib.env')
    local str = require('render-markdown.lib.str')

    -- account for conceal lines marks allowing us to reduce window height
    local height = vim.api.nvim_win_text_height(win, {}).all ---@type integer
    for _, extmark in ipairs(extmarks) do
        if extmark:get().opts.conceal_lines then
            height = height - 1
        end
    end
    if height < vim.api.nvim_win_get_height(win) then
        vim.api.nvim_win_set_height(win, height)
    end

    -- disable line wrapping if it is not needed to contain the text
    local width = 0
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        width = math.max(width, str.width(line))
    end
    if width <= vim.api.nvim_win_get_width(win) then
        env.win.set(win, 'wrap', false)
    end
end

---@param cause string
function M.release(cause)
    local message = {
        'MeanderingProgrammer/render-markdown.nvim',
        cause,
        'you are running an old build of neovim that has now been released',
        'your build does not have all the features that are in the release',
        'update your build or switch to the release version',
    }
    vim.schedule(function()
        vim.notify_once(table.concat(message, '\n'), vim.log.levels.ERROR)
    end)
end

return M
