---@class render.md.Compat
local M = {}

---@param win integer
---@param extmarks render.md.Extmark[]
---@see vim.lsp.util.open_floating_preview
function M.lsp_window_height(win, extmarks)
    -- This is a fragile way of identifying whether this is a floating LSP buffer,
    -- comes from the implementation and not from any documentation
    local lsp_buf = pcall(vim.api.nvim_win_get_var, win, 'lsp_floating_bufnr')
    if not lsp_buf then
        return
    end
    local concealed = 0
    for _, extmark in ipairs(extmarks) do
        if extmark:get().opts.conceal_lines ~= nil then
            concealed = concealed + 1
        end
    end
    if concealed == 0 then
        return
    end
    local height = vim.api.nvim_win_text_height(win, {}).all - concealed
    if height < vim.api.nvim_win_get_height(win) then
        vim.api.nvim_win_set_height(win, height)
    end
end

return M
