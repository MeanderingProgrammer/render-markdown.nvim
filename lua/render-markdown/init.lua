local state = require('render-markdown.state')
local ui = require('render-markdown.ui')
local util = require('render-markdown.util')

local M = {}

---@class render.md.UserTableHighlights
---@field public head? string
---@field public row? string

---@class render.md.UserCheckboxHighlights
---@field public unchecked? string
---@field public checked? string

---@class render.md.UserHeadingHighlights
---@field public backgrounds? string[]
---@field public foregrounds? string[]

---@class render.md.UserHighlights
---@field public heading? render.md.UserHeadingHighlights
---@field public dash? string
---@field public code? string
---@field public bullet? string
---@field public checkbox? render.md.UserCheckboxHighlights
---@field public table? render.md.UserTableHighlights
---@field public latex? string
---@field public quote? string

---@class render.md.UserConceal
---@field public default? integer
---@field public rendered? integer

---@class render.md.UserCheckbox
---@field public unchecked? string
---@field public checked? string

---@class render.md.UserConfig
---@field public start_enabled? boolean
---@field public max_file_size? number
---@field public markdown_query? string
---@field public inline_query? string
---@field public log_level? 'debug'|'error'
---@field public file_types? string[]
---@field public render_modes? string[]
---@field public headings? string[]
---@field public dash? string
---@field public bullets? string[]
---@field public checkbox? render.md.UserCheckbox
---@field public quote? string
---@field public conceal? render.md.UserConceal
---@field public fat_tables? boolean
---@field public highlights? render.md.UserHighlights

---@param opts? render.md.UserConfig
function M.setup(opts)
    ---@type render.md.Config
    local default_config = {
        start_enabled = true,
        max_file_size = 1.5,
        markdown_query = [[
            (atx_heading [
                (atx_h1_marker)
                (atx_h2_marker)
                (atx_h3_marker)
                (atx_h4_marker)
                (atx_h5_marker)
                (atx_h6_marker)
            ] @heading)

            (thematic_break) @dash

            (fenced_code_block) @code

            [
                (list_marker_plus)
                (list_marker_minus)
                (list_marker_star)
            ] @list_marker

            (task_list_marker_unchecked) @checkbox_unchecked
            (task_list_marker_checked) @checkbox_checked

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
        log_level = 'error',
        file_types = { 'markdown' },
        render_modes = { 'n', 'c' },
        headings = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        dash = '—',
        bullets = { '●', '○', '◆', '◇' },
        checkbox = {
            unchecked = '󰄱 ',
            checked = ' ',
        },
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
            dash = 'LineNr',
            code = 'ColorColumn',
            bullet = 'Normal',
            checkbox = {
                unchecked = '@markup.list.unchecked',
                checked = '@markup.heading',
            },
            table = {
                head = '@markup.heading',
                row = 'Normal',
            },
            latex = '@markup.math',
            quote = '@markup.quote',
        },
    }
    state.config = vim.tbl_deep_extend('force', default_config, opts or {})
    state.enabled = state.config.start_enabled
    state.markdown_query = vim.treesitter.query.parse('markdown', state.config.markdown_query)
    state.inline_query = vim.treesitter.query.parse('markdown_inline', state.config.inline_query)

    -- Call immediately to re-render on LazyReload
    vim.schedule(function()
        ui.refresh(vim.api.nvim_get_current_buf())
    end)

    local group = vim.api.nvim_create_augroup('RenderMarkdown', { clear = true })
    vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
        group = group,
        callback = function(event)
            local was_rendered = vim.tbl_contains(state.config.render_modes, vim.v.event.old_mode)
            local should_render = vim.tbl_contains(state.config.render_modes, vim.v.event.new_mode)
            -- Only need to re-render if render state is changing. I.e. going from normal mode to
            -- command mode with the default config, both are rendered, so no point re-rendering
            if was_rendered ~= should_render then
                vim.schedule(function()
                    ui.refresh(event.buf)
                end)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ 'WinResized' }, {
        group = group,
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                local buf = util.win_to_buf(win)
                vim.schedule(function()
                    ui.refresh(buf)
                end)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ 'FileChangedShellPost', 'FileType', 'TextChanged' }, {
        group = group,
        callback = function(event)
            vim.schedule(function()
                ui.refresh(event.buf)
            end)
        end,
    })

    local description = 'Switch between enabling & disabling render markdown plugin'
    vim.api.nvim_create_user_command('RenderMarkdownToggle', M.toggle, { desc = description })
end

M.toggle = function()
    state.enabled = not state.enabled
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        vim.schedule(function()
            if state.enabled then
                ui.refresh(buf)
            else
                ui.clear_valid(buf)
            end
        end)
    end
end

return M
