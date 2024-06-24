local state = require('render-markdown.state')
local ui = require('render-markdown.ui')
local util = require('render-markdown.util')

local M = {}

---@class render.md.UserCallout
---@field public note? string
---@field public tip? string
---@field public important? string
---@field public warning? string
---@field public caution? string

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
---@field public callout? render.md.UserCallout

---@class render.md.Handler
---@field public render fun(namespace: integer, root: TSNode, buf: integer)
---@field public extends? boolean

---@class render.md.WindowOption
---@field public default any
---@field public rendered any

---@class render.md.UserCheckbox
---@field public unchecked? string
---@field public checked? string

---@class render.md.UserConfig
---@field public start_enabled? boolean
---@field public latex_enabled? boolean
---@field public max_file_size? number
---@field public markdown_query? string
---@field public inline_query? string
---@field public latex_converter? string
---@field public log_level? 'debug'|'error'
---@field public file_types? string[]
---@field public render_modes? string[]
---@field public headings? string[]
---@field public dash? string
---@field public bullets? string[]
---@field public checkbox? render.md.UserCheckbox
---@field public quote? string
---@field public callout? render.md.UserCallout
---@field public win_options? table<string, render.md.WindowOption>
---@field public table_style? 'full'|'normal'|'none'
---@field public cell_style? 'overlay'|'raw'
---@field public custom_handlers? table<string, render.md.Handler>
---@field public highlights? render.md.UserHighlights

---@type render.md.Config
M.default_config = {
    -- Whether Markdown should be rendered by default or not
    start_enabled = true,
    -- Whether LaTeX should be rendered, mainly used for health check
    latex_enabled = true,
    -- Maximum file size (in MB) that this plugin will attempt to render
    -- Any file larger than this will effectively be ignored
    max_file_size = 1.5,
    -- Capture groups that get pulled from markdown
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
        (block_quote (block_continuation) @quote_marker)
        (block_quote (paragraph (block_continuation) @quote_marker))
        (block_quote (paragraph (inline (block_continuation) @quote_marker)))

        (pipe_table) @table
        (pipe_table_header) @table_head
        (pipe_table_delimiter_row) @table_delim
        (pipe_table_row) @table_row
    ]],
    -- Capture groups that get pulled from inline markdown
    inline_query = [[
        (code_span) @code

        (shortcut_link) @callout
    ]],
    -- Executable used to convert latex formula to rendered unicode
    latex_converter = 'latex2text',
    -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'
    -- Only intended to be used for plugin development / debugging
    log_level = 'error',
    -- Filetypes this plugin will run on
    file_types = { 'markdown' },
    -- Vim modes that will show a rendered view of the markdown file
    -- All other modes will be uneffected by this plugin
    render_modes = { 'n', 'c' },
    -- Characters that will replace the # at the start of headings
    headings = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    -- Character to use for the horizontal break
    dash = '─',
    -- Character to use for the bullet points in lists
    bullets = { '●', '○', '◆', '◇' },
    checkbox = {
        -- Character that will replace the [ ] in unchecked checkboxes
        unchecked = '󰄱 ',
        -- Character that will replace the [x] in checked checkboxes
        checked = '󰱒 ',
    },
    -- Character that will replace the > at the start of block quotes
    quote = '┃',
    -- Symbol / text to use for different callouts
    callout = {
        note = '󰋽 Note',
        tip = '󰌶 Tip',
        important = '󰅾 Important',
        warning = '󰀪 Warning',
        caution = '󰳦 Caution',
    },
    -- Window options to use that change between rendered and raw view
    win_options = {
        -- See :h 'conceallevel'
        conceallevel = {
            -- Used when not being rendered, get user setting
            default = vim.api.nvim_get_option_value('conceallevel', {}),
            -- Used when being rendered, concealed text is completely hidden
            rendered = 3,
        },
        -- See :h 'concealcursor'
        concealcursor = {
            -- Used when not being rendered, get user setting
            default = vim.api.nvim_get_option_value('concealcursor', {}),
            -- Used when being rendered, conceal text in all modes
            rendered = 'nvic',
        },
    },
    -- Determines how tables are rendered
    --  full: adds a line above and below tables + normal behavior
    --  normal: renders the rows of tables
    --  none: disables rendering, use this if you prefer having cell highlights
    table_style = 'full',
    -- Determines how table cells are rendered
    --  overlay: writes over the top of cells removing conealing and highlighting
    --  raw: will leave the cells as they and only replace table related symbols
    cell_style = 'overlay',
    -- Mapping from treesitter language to user defined handlers
    -- See 'Custom Handlers' section for more info
    custom_handlers = {},
    -- Define the highlight groups to use when rendering various components
    highlights = {
        heading = {
            -- Background of heading line
            backgrounds = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
            -- Foreground of heading character only
            foregrounds = {
                'markdownH1',
                'markdownH2',
                'markdownH3',
                'markdownH4',
                'markdownH5',
                'markdownH6',
            },
        },
        -- Horizontal break
        dash = 'LineNr',
        -- Code blocks
        code = 'ColorColumn',
        -- Bullet points in list
        bullet = 'Normal',
        checkbox = {
            -- Unchecked checkboxes
            unchecked = '@markup.list.unchecked',
            -- Checked checkboxes
            checked = '@markup.heading',
        },
        table = {
            -- Header of a markdown table
            head = '@markup.heading',
            -- Non header rows in a markdown table
            row = 'Normal',
        },
        -- LaTeX blocks
        latex = '@markup.math',
        -- Quote character in a block quote
        quote = '@markup.quote',
        -- Highlights to use for different callouts
        callout = {
            note = 'DiagnosticInfo',
            tip = 'DiagnosticOk',
            important = 'DiagnosticHint',
            warning = 'DiagnosticWarn',
            caution = 'DiagnosticError',
        },
    },
}

---@param opts? render.md.UserConfig
function M.setup(opts)
    state.config = vim.tbl_deep_extend('force', M.default_config, opts or {})
    state.enabled = state.config.start_enabled
    state.markdown_query = vim.treesitter.query.parse('markdown', state.config.markdown_query)
    state.inline_query = vim.treesitter.query.parse('markdown_inline', state.config.inline_query)

    -- Call immediately to re-render on LazyReload
    ui.schedule_refresh(vim.api.nvim_get_current_buf())

    local group = vim.api.nvim_create_augroup('RenderMarkdown', { clear = true })
    vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
        group = group,
        callback = function(event)
            local render_modes = state.config.render_modes
            local prev_rendered = vim.tbl_contains(render_modes, string.sub(vim.v.event.old_mode, 1, 1))
            local should_render = vim.tbl_contains(render_modes, string.sub(vim.v.event.new_mode, 1, 1))
            -- Only need to re-render if render state is changing. I.e. going from normal mode to
            -- command mode with the default config, both are rendered, so no point re-rendering
            if prev_rendered ~= should_render then
                ui.schedule_refresh(event.buf)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ 'WinResized' }, {
        group = group,
        callback = function()
            for _, win in ipairs(vim.v.event.windows) do
                local buf = util.win_to_buf(win)
                ui.schedule_refresh(buf)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ 'FileChangedShellPost', 'FileType', 'TextChanged' }, {
        group = group,
        callback = function(event)
            ui.schedule_refresh(event.buf)
        end,
    })

    local description = 'Switch between enabling & disabling render markdown plugin'
    vim.api.nvim_create_user_command('RenderMarkdownToggle', M.toggle, { desc = description })
end

M.toggle = function()
    state.enabled = not state.enabled
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if state.enabled then
            ui.schedule_refresh(buf)
        else
            ui.schedule_clear(buf)
        end
    end
end

return M
