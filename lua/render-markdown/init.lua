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
---@field public quote? string

---@class UserConceal
---@field public default? integer
---@field public rendered? integer

---@class UserConfig
---@field public markdown_query? string
---@field public inline_query? string
---@field public file_types? string[]
---@field public render_modes? string[]
---@field public headings? string[]
---@field public bullet? string
---@field public quote? string
---@field public conceal? UserConceal
---@field public fat_tables? boolean
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

            (block_quote (block_quote_marker) @quote_marker)
            (block_quote (paragraph (inline (block_continuation) @quote_marker)))

            (pipe_table) @table
            (pipe_table_header) @table_head
            (pipe_table_delimiter_row) @table_delim
            (pipe_table_row) @table_row
        ]],
        inline_query = [[
            (code_span) @code
        ]],
        file_types = { 'markdown' },
        render_modes = { 'n', 'c' },
        headings = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        bullet = '○',
        quote = '┃',
        conceal = {
            default = vim.opt.conceallevel:get(),
            rendered = 3,
        },
        fat_tables = true,
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
            latex = '@markup.math',
            quote = '@markup.quote',
        },
    }
    state.enabled = true
    state.config = vim.tbl_deep_extend('force', default_config, opts or {})
    state.markdown_query = vim.treesitter.query.parse('markdown', state.config.markdown_query)
    state.inline_query = vim.treesitter.query.parse('markdown_inline', state.config.inline_query)

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
