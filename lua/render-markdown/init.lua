local state = require('render-markdown.state')
local ui = require('render-markdown.ui')

local M = {}

---@class UserTableHighlights
---@field public head? string
---@field public row? string

---@class UserHeadingHighlights
---@field public backgrounds? string[]
---@field public foregrounds? string[]

---@class UserHighlights
---@field public heading? UserHeadingHighlights
---@field public code? string
---@field public bullet? string
---@field public table? UserTableHighlights
---@field public latex? string

---@class UserConfig
---@field public markdown_query? string
---@field public file_types? string[]
---@field public render_modes? string[]
---@field public headings? string[]
---@field public bullet? string
---@field public highlights? UserHighlights

---@param opts UserConfig|nil
function M.setup(opts)
    ---@type Config
    local default_config = {
        markdown_query = [[
            (atx_heading [
                (atx_h1_marker)
                (atx_h2_marker)
                (atx_h3_marker)
                (atx_h4_marker)
                (atx_h5_marker)
                (atx_h6_marker)
            ] @heading)

            (fenced_code_block) @code

            [
                (list_marker_plus)
                (list_marker_minus)
                (list_marker_star)
            ] @list_marker

            (pipe_table_header) @table_head
            (pipe_table_delimiter_row) @table_delim
            (pipe_table_row) @table_row
        ]],
        file_types = { 'markdown' },
        render_modes = { 'n', 'c' },
        headings = { '󰲡', '󰲣', '󰲥', '󰲧', '󰲩', '󰲫' },
        bullet = '○',
        highlights = {
            heading = {
                backgrounds = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
                foregrounds = {
                    'markdownH1',
                    'markdownH2',
                    'markdownH3',
                    'markdownH4',
                    'markdownH5',
                    'markdownH6',
                },
            },
            code = 'ColorColumn',
            bullet = 'Normal',
            table = {
                head = '@markup.heading',
                row = 'Normal',
            },
            latex = 'Special',
        },
    }
    state.enabled = true
    state.config = vim.tbl_deep_extend('force', default_config, opts or {})
    state.markdown_query = vim.treesitter.query.parse('markdown', state.config.markdown_query)

    -- Call immediately to re-render on LazyReload
    vim.schedule(ui.refresh)

    vim.api.nvim_create_autocmd({
        'FileChangedShellPost',
        'ModeChanged',
        'Syntax',
        'TextChanged',
        'WinResized',
    }, {
        group = vim.api.nvim_create_augroup('RenderMarkdown', { clear = true }),
        callback = function()
            vim.schedule(ui.refresh)
        end,
    })

    vim.api.nvim_create_user_command(
        'RenderMarkdownToggle',
        M.toggle,
        { desc = 'Switch between enabling & disabling render markdown plugin' }
    )
end

M.toggle = function()
    if state.enabled then
        state.enabled = false
        vim.schedule(ui.clear)
    else
        state.enabled = true
        -- Call to refresh must happen after state change
        vim.schedule(ui.refresh)
    end
end

return M
