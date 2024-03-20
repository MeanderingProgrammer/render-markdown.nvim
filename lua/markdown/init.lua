local state = require('markdown.state')

local M = {}

---@class UserHighlights
---@field public heading? string
---@field public code? string
---@field public bullet? string

---@class UserConfig
---@field public query? Query
---@field public render_modes? string[]
---@field public bullet? string
---@field public highlights? Highlights

---@param opts UserConfig|nil
function M.setup(opts)
    --[[
    Reference for pre-defined highlight groups and colors
    ColorColumn     bg = 1f1d2e (dark gray / purple)
    PmenuExtra      bg = 1f1d2e (dark gray / purple)                fg = 6e6a86 (light purple)
    CursorColumn    bg = 26233a (more purple version of 1f1d2e)
    PmenuSel        bg = 26233a (more purple version of 1f1d2e)     fg = e0def4 (white / pink)
    CurSearch       bg = f6c177 (light orange)                      fg = 191724 (dark gray)
    DiffAdd         bg = 333c48 (gray / little bit blue)
    DiffChange      bg = 433842 (pink / gray)
    DiffDelete      bg = 43293a (darker version of 433842)
    Visual          bg = 403d52 (lighter version of 1f1d2e)
    MatchParen      bg = 1f2e3f (deep blue)                         fg = 31748f (teel)
    ]]

    ---@type Config
    local default_config = {
        query = vim.treesitter.query.parse(
            'markdown',
            [[
                (atx_heading [
                    (atx_h1_marker)
                    (atx_h2_marker)
                    (atx_h3_marker)
                    (atx_h4_marker)
                    (atx_h5_marker)
                    (atx_h6_marker)
                ] @heading)

                (fenced_code_block) @code

                (list_item) @item
            ]]
        ),
        render_modes = { 'n', 'c' },
        bullet = '○',
        highlights = {
            headings = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
            code = 'ColorColumn',
            bullet = 'Normal',
        },
    }
    state.config = vim.tbl_deep_extend('force', default_config, opts or {})

    -- Call immediately to re-render on LazyReload
    M.refresh()

    vim.api.nvim_create_autocmd({
        'FileChangedShellPost',
        'ModeChanged',
        'Syntax',
        'TextChanged',
        'WinResized',
    }, {
        group = vim.api.nvim_create_augroup('Markdown', { clear = true }),
        callback = function()
            vim.schedule(M.refresh)
        end,
    })
end

M.namespace = vim.api.nvim_create_namespace('markdown.nvim')

M.refresh = function()
    if vim.bo.filetype ~= 'markdown' then
        return
    end

    -- Remove existing highlights / virtual text
    vim.api.nvim_buf_clear_namespace(0, M.namespace, 0, -1)

    if not vim.tbl_contains(state.config.render_modes, vim.fn.mode()) then
        return
    end

    local highlights = state.config.highlights

    local root = vim.treesitter.get_parser(0, 'markdown'):parse()[1]:root()
    ---@diagnostic disable-next-line: missing-parameter
    for id, node in state.config.query:iter_captures(root, 0) do
        local capture = state.config.query.captures[id]
        local start_row, start_col, end_row, end_col = node:range()

        if capture == 'heading' then
            local level = #vim.treesitter.get_node_text(node, 0)
            local highlight = highlights.headings[((level - 1) % #highlights.headings) + 1]
            vim.api.nvim_buf_set_extmark(0, M.namespace, start_row, 0, {
                end_row = end_row + 1,
                end_col = 0,
                hl_group = highlight,
            })
        elseif capture == 'code' then
            vim.api.nvim_buf_set_extmark(0, M.namespace, start_row, 0, {
                end_row = end_row,
                end_col = 0,
                hl_group = highlights.code,
                hl_eol = true,
            })
        elseif capture == 'item' then
            vim.api.nvim_buf_set_extmark(0, M.namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { { state.config.bullet, highlights.bullet } },
                virt_text_pos = 'overlay',
            })
        else
            -- Should only get here if user provides custom capture, currently unhandled
            vim.print('Unhandled capture: ' .. capture)
        end
    end
end

return M
