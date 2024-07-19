local colors = require('render-markdown.colors')
local manager = require('render-markdown.manager')
local state = require('render-markdown.state')

---@class render.md.Init
local M = {}

---@class render.md.Mark
---@field public conceal boolean
---@field public start_row integer
---@field public start_col integer
---@field public opts vim.api.keyset.set_extmark

---@class render.md.Handler
---@field public parse fun(root: TSNode, buf: integer): render.md.Mark[]
---@field public extends? boolean

---@class render.md.UserWindowOption
---@field public default? number|string
---@field public rendered? number|string

---@class render.md.UserSign
---@field public enabled? boolean
---@field public exclude? render.md.UserExclude
---@field public highlight? string

---@class render.md.UserLink
---@field public enabled? boolean
---@field public image? string
---@field public hyperlink? string
---@field public highlight? string

---@class render.md.UserPipeTable
---@field public enabled? boolean
---@field public style? 'full'|'normal'|'none'
---@field public cell? 'padded'|'raw'|'overlay'
---@field public border? string[]
---@field public head? string
---@field public row? string
---@field public filler? string

---@class render.md.UserCustomComponent
---@field public raw? string
---@field public rendered? string
---@field public highlight? string

---@class render.md.UserCheckboxComponent
---@field public icon? string
---@field public highlight? string

---@class render.md.UserCheckbox
---@field public enabled? boolean
---@field public unchecked? render.md.UserCheckboxComponent
---@field public checked? render.md.UserCheckboxComponent
---@field public custom? table<string, render.md.CustomComponent>

---@class render.md.UserBullet
---@field public enabled? boolean
---@field public icons? string[]
---@field public highlight? string

---@class render.md.UserBasicComponent
---@field public enabled? boolean
---@field public icon? string
---@field public highlight? string

---@class render.md.UserCode
---@field public enabled? boolean
---@field public sign? boolean
---@field public style? 'full'|'normal'|'language'|'none'
---@field public left_pad? integer
---@field public border? 'thin'|'thick'
---@field public above? string
---@field public below? string
---@field public highlight? string

---@class render.md.UserHeading
---@field public enabled? boolean
---@field public sign? boolean
---@field public icons? string[]
---@field public signs? string[]
---@field public backgrounds? string[]
---@field public foregrounds? string[]

---@class render.md.UserLatex
---@field public enabled? boolean
---@field public converter? string
---@field public highlight? string

---@class render.md.UserAntiConceal
---@field public enabled? boolean

---@class render.md.UserExclude
---@field public buftypes? string[]

---@class render.md.UserConfig
---@field public enabled? boolean
---@field public max_file_size? number
---@field public markdown_query? string
---@field public markdown_quote_query? string
---@field public inline_query? string
---@field public inline_link_query? string
---@field public log_level? 'debug'|'error'
---@field public file_types? string[]
---@field public render_modes? string[]
---@field public exclude? render.md.UserExclude
---@field public anti_conceal? render.md.UserAntiConceal
---@field public latex? render.md.UserLatex
---@field public heading? render.md.UserHeading
---@field public code? render.md.UserCode
---@field public dash? render.md.UserBasicComponent
---@field public bullet? render.md.UserBullet
---@field public checkbox? render.md.UserCheckbox
---@field public quote? render.md.UserBasicComponent
---@field public pipe_table? render.md.UserPipeTable
---@field public callout? table<string, render.md.UserCustomComponent>
---@field public link? render.md.UserLink
---@field public sign? render.md.UserSign
---@field public win_options? table<string, render.md.UserWindowOption>
---@field public custom_handlers? table<string, render.md.Handler>

---@type render.md.Config
M.default_config = {
    -- Whether Markdown should be rendered by default or not
    enabled = true,
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

        (block_quote) @quote

        (pipe_table) @table
    ]],
    -- Capture groups that get pulled from quote nodes
    markdown_quote_query = [[
        [
            (block_quote_marker)
            (block_continuation)
        ] @quote_marker
    ]],
    -- Capture groups that get pulled from inline markdown
    inline_query = [[
        (code_span) @code

        (shortcut_link) @callout

        [(inline_link) (image)] @link
    ]],
    -- Query to be able to identify links in nodes
    inline_link_query = '[(inline_link) (image)] @link',
    -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'
    -- Only intended to be used for plugin development / debugging
    log_level = 'error',
    -- Filetypes this plugin will run on
    file_types = { 'markdown' },
    -- Vim modes that will show a rendered view of the markdown file
    -- All other modes will be uneffected by this plugin
    render_modes = { 'n', 'c' },
    exclude = {
        -- Buftypes ignored by this plugin, see :h 'buftype'
        buftypes = {},
    },
    anti_conceal = {
        -- This enables hiding any added text on the line the cursor is on
        -- This does have a performance penalty as we must listen to the 'CursorMoved' event
        enabled = true,
    },
    latex = {
        -- Whether LaTeX should be rendered, mainly used for health check
        enabled = true,
        -- Executable used to convert latex formula to rendered unicode
        converter = 'latex2text',
        -- Highlight for LaTeX blocks
        highlight = 'RenderMarkdownMath',
    },
    heading = {
        -- Turn on / off heading icon & background rendering
        enabled = true,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Replaces '#+' of 'atx_h._marker'
        -- The number of '#' in the heading determines the 'level'
        -- The 'level' is used to index into the array using a cycle
        -- The result is left padded with spaces to hide any additional '#'
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        -- Added to the sign column if enabled
        -- The 'level' is used to index into the array using a cycle
        signs = { '󰫎 ' },
        -- The 'level' is used to index into the array using a clamp
        -- Highlight for the heading icon and extends through the entire line
        backgrounds = {
            'RenderMarkdownH1Bg',
            'RenderMarkdownH2Bg',
            'RenderMarkdownH3Bg',
            'RenderMarkdownH4Bg',
            'RenderMarkdownH5Bg',
            'RenderMarkdownH6Bg',
        },
        -- The 'level' is used to index into the array using a clamp
        -- Highlight for the heading and sign icons
        foregrounds = {
            'RenderMarkdownH1',
            'RenderMarkdownH2',
            'RenderMarkdownH3',
            'RenderMarkdownH4',
            'RenderMarkdownH5',
            'RenderMarkdownH6',
        },
    },
    code = {
        -- Turn on / off code block & inline code rendering
        enabled = true,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Determines how code blocks & inline code are rendered:
        --  none: disables all rendering
        --  normal: adds highlight group to code blocks & inline code, adds padding to code blocks
        --  language: adds language icon to sign column if enabled and icon + name above code blocks
        --  full: normal + language
        style = 'full',
        -- Amount of padding to add to the left of code blocks
        left_pad = 0,
        -- Determins how the top / bottom of code block are rendered:
        --  thick: use the same highlight as the code body
        --  thin: when lines are empty overlay the above & below icons
        border = 'thin',
        -- Used above code blocks for thin border
        above = '▄',
        -- Used below code blocks for thin border
        below = '▀',
        -- Highlight for code blocks & inline code
        highlight = 'RenderMarkdownCode',
    },
    dash = {
        -- Turn on / off thematic break rendering
        enabled = true,
        -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'
        -- The icon gets repeated across the window's width
        icon = '─',
        -- Highlight for the whole line generated from the icon
        highlight = 'RenderMarkdownDash',
    },
    bullet = {
        -- Turn on / off list bullet rendering
        enabled = true,
        -- Replaces '-'|'+'|'*' of 'list_item'
        -- How deeply nested the list is determines the 'level'
        -- The 'level' is used to index into the array using a cycle
        -- If the item is a 'checkbox' a conceal is used to hide the bullet instead
        icons = { '●', '○', '◆', '◇' },
        -- Highlight for the bullet icon
        highlight = 'RenderMarkdownBullet',
    },
    -- Checkboxes are a special instance of a 'list_item' that start with a 'shortcut_link'
    -- There are two special states for unchecked & checked defined in the markdown grammar
    checkbox = {
        -- Turn on / off checkbox state rendering
        enabled = true,
        unchecked = {
            -- Replaces '[ ]' of 'task_list_marker_unchecked'
            icon = '󰄱 ',
            -- Highlight for the unchecked icon
            highlight = 'RenderMarkdownUnchecked',
        },
        checked = {
            -- Replaces '[x]' of 'task_list_marker_checked'
            icon = '󰱒 ',
            -- Highligh for the checked icon
            highlight = 'RenderMarkdownChecked',
        },
        -- Define custom checkbox states, more involved as they are not part of the markdown grammar
        -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks
        -- Can specify as many additional states as you like following the 'todo' pattern below
        --   The key in this case 'todo' is for healthcheck and to allow users to change its values
        --   'raw': Matched against the raw text of a 'shortcut_link'
        --   'rendered': Replaces the 'raw' value when rendering
        --   'highlight': Highlight for the 'rendered' icon
        custom = {
            todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
        },
    },
    quote = {
        -- Turn on / off block quote & callout rendering
        enabled = true,
        -- Replaces '>' of 'block_quote'
        icon = '▋',
        -- Highlight for the quote icon
        highlight = 'RenderMarkdownQuote',
    },
    pipe_table = {
        -- Turn on / off pipe table rendering
        enabled = true,
        -- Determines how the table as a whole is rendered:
        --  none: disables all rendering
        --  normal: applies the 'cell' style rendering to each row of the table
        --  full: normal + a top & bottom line that fill out the table when lengths match
        style = 'full',
        -- Determines how individual cells of a table are rendered:
        --  overlay: writes completely over the table, removing conceal behavior and highlights
        --  raw: replaces only the '|' characters in each row, leaving the cells unmodified
        --  padded: raw + cells are padded with inline extmarks to make up for any concealed text
        cell = 'padded',
        -- Characters used to replace table border
        -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal
        -- stylua: ignore
        border = {
            '┌', '┬', '┐',
            '├', '┼', '┤',
            '└', '┴', '┘',
            '│', '─',
        },
        -- Highlight for table heading, delimiter, and the line above
        head = 'RenderMarkdownTableHead',
        -- Highlight for everything else, main table rows and the line below
        row = 'RenderMarkdownTableRow',
        -- Highlight for inline padding used to add back concealed space
        filler = 'RenderMarkdownTableFill',
    },
    -- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'
    -- Can specify as many additional values as you like following the pattern from any below, such as 'note'
    --   The key in this case 'note' is for healthcheck and to allow users to change its values
    --   'raw': Matched against the raw text of a 'shortcut_link', case insensitive
    --   'rendered': Replaces the 'raw' value when rendering
    --   'highlight': Highlight for the 'rendered' text and quote markers
    callout = {
        note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
        tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
        important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint' },
        warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
        caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
        -- Obsidian: https://help.a.md/Editing+and+formatting/Callouts
        abstract = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo' },
        todo = { raw = '[!TODO]', rendered = '󰗡 Todo', highlight = 'RenderMarkdownInfo' },
        success = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess' },
        question = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn' },
        failure = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError' },
        danger = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError' },
        bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError' },
        example = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint' },
        quote = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote' },
    },
    link = {
        -- Turn on / off inline link icon rendering
        enabled = true,
        -- Inlined with 'image' elements
        image = '󰥶 ',
        -- Inlined with 'inline_link' elements
        hyperlink = '󰌹 ',
        -- Applies to the inlined icon
        highlight = 'RenderMarkdownLink',
    },
    sign = {
        -- Turn on / off sign rendering
        enabled = true,
        -- More granular mechanism, disable signs within specific buftypes
        exclude = {
            buftypes = { 'nofile' },
        },
        -- Applies to background of sign text
        highlight = 'RenderMarkdownSign',
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
            -- Used when being rendered, disable concealing text in all modes
            rendered = '',
        },
    },
    -- Mapping from treesitter language to user defined handlers
    -- See 'Custom Handlers' document for more info
    custom_handlers = {},
}

---@param opts? render.md.UserConfig
function M.setup(opts)
    state.config = vim.tbl_deep_extend('force', M.default_config, opts or {})
    state.enabled = state.config.enabled
    vim.schedule(function()
        state.markdown_query = vim.treesitter.query.parse('markdown', state.config.markdown_query)
        state.markdown_quote_query = vim.treesitter.query.parse('markdown', state.config.markdown_quote_query)
        state.inline_query = vim.treesitter.query.parse('markdown_inline', state.config.inline_query)
        state.inline_link_query = vim.treesitter.query.parse('markdown_inline', state.config.inline_link_query)
    end)

    colors.setup()
    manager.setup()

    vim.api.nvim_create_user_command('RenderMarkdown', M.command, {
        nargs = '*',
        desc = 'markdown.nvim commands',
        complete = function(_, cmdline)
            if cmdline:find('RenderMarkdown%s+%S+%s+.*') then
                return {}
            elseif cmdline:find('RenderMarkdown%s+') then
                return { 'enable', 'disable', 'toggle' }
            else
                return {}
            end
        end,
    })
end

---@param opts any
M.command = function(opts)
    local args = opts.fargs
    if #args == 0 then
        M.enable()
    elseif #args == 1 then
        if args[1] == 'enable' then
            M.enable()
        elseif args[1] == 'disable' then
            M.disable()
        elseif args[1] == 'toggle' then
            M.toggle()
        else
            vim.notify('markdown.nvim: unexpected command: ' .. args[1], vim.log.levels.ERROR)
        end
    else
        vim.notify('markdown.nvim: unexpected # arguments: ' .. #args, vim.log.levels.ERROR)
    end
end

M.enable = function()
    manager.set_all(true)
end

M.disable = function()
    manager.set_all(false)
end

M.toggle = function()
    manager.set_all(not state.enabled)
end

return M
