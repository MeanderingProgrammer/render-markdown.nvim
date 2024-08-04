---@class render.md.Init: render.md.Api
local M = {}

---@class (exact) render.md.Mark
---@field public conceal boolean
---@field public start_row integer
---@field public start_col integer
---@field public opts vim.api.keyset.set_extmark

---@class (exact) render.md.Handler
---@field public parse fun(root: TSNode, buf: integer): render.md.Mark[]
---@field public extends? boolean

---@class (exact) render.md.UserLatex
---@field public enabled? boolean
---@field public converter? string
---@field public highlight? string
---@field public top_pad? integer
---@field public bottom_pad? integer

---@class (exact) render.md.UserWindowOption
---@field public default? number|string|boolean
---@field public rendered? number|string|boolean

---@class (exact) render.md.UserSign
---@field public enabled? boolean
---@field public highlight? string

---@class (exact) render.md.UserLinkComponent
---@field public pattern? string
---@field public icon? string
---@field public highlight? string

---@class (exact) render.md.UserLink
---@field public enabled? boolean
---@field public image? string
---@field public hyperlink? string
---@field public highlight? string
---@field public custom? table<string, render.md.UserLinkComponent>

---@class (exact) render.md.UserPipeTable
---@field public enabled? boolean
---@field public style? 'full'|'normal'|'none'
---@field public cell? 'padded'|'raw'|'overlay'
---@field public border? string[]
---@field public alignment_indicator? string
---@field public head? string
---@field public row? string
---@field public filler? string

---@class (exact) render.md.UserCustomComponent
---@field public raw? string
---@field public rendered? string
---@field public highlight? string

---@class (exact) render.md.UserQuote
---@field public enabled? boolean
---@field public icon? string
---@field public repeat_linebreak? boolean
---@field public highlight? string

---@class (exact) render.md.UserCheckboxComponent
---@field public icon? string
---@field public highlight? string

---@class (exact) render.md.UserCheckbox
---@field public enabled? boolean
---@field public unchecked? render.md.UserCheckboxComponent
---@field public checked? render.md.UserCheckboxComponent
---@field public custom? table<string, render.md.CustomComponent>

---@class (exact) render.md.UserBullet
---@field public enabled? boolean
---@field public icons? string[]
---@field public right_pad? integer
---@field public highlight? string

---@class (exact) render.md.UserDash
---@field public enabled? boolean
---@field public icon? string
---@field public width? 'full'|integer
---@field public highlight? string

---@class (exact) render.md.UserCode
---@field public enabled? boolean
---@field public sign? boolean
---@field public style? 'full'|'normal'|'language'|'none'
---@field public position? 'left'|'right'
---@field public disable_background? string[]
---@field public left_pad? integer
---@field public right_pad? integer
---@field public width? 'full'|'block'
---@field public border? 'thin'|'thick'
---@field public above? string
---@field public below? string
---@field public highlight? string
---@field public highlight_inline? string

---@class (exact) render.md.UserHeading
---@field public enabled? boolean
---@field public sign? boolean
---@field public position? 'overlay'|'inline'
---@field public icons? string[]
---@field public signs? string[]
---@field public width? 'full'|'block'
---@field public backgrounds? string[]
---@field public foregrounds? string[]

---@class (exact) render.md.UserAntiConceal
---@field public enabled? boolean

---@class (exact) render.md.UserConfigOverrides
---@field public buftype? table<string, render.md.UserBufferConfig>

---@class (exact) render.md.UserBufferConfig
---@field public enabled? boolean
---@field public max_file_size? number
---@field public debounce? integer
---@field public render_modes? string[]
---@field public anti_conceal? render.md.UserAntiConceal
---@field public heading? render.md.UserHeading
---@field public code? render.md.UserCode
---@field public dash? render.md.UserDash
---@field public bullet? render.md.UserBullet
---@field public checkbox? render.md.UserCheckbox
---@field public quote? render.md.UserQuote
---@field public pipe_table? render.md.UserPipeTable
---@field public callout? table<string, render.md.UserCustomComponent>
---@field public link? render.md.UserLink
---@field public sign? render.md.UserSign
---@field public win_options? table<string, render.md.UserWindowOption>

---@class (exact) render.md.UserConfig: render.md.UserBufferConfig
---@field public markdown_query? string
---@field public markdown_quote_query? string
---@field public inline_query? string
---@field public log_level? 'debug'|'error'
---@field public file_types? string[]
---@field public acknowledge_conflicts? boolean
---@field public latex? render.md.UserLatex
---@field public overrides? render.md.UserConfigOverrides
---@field public custom_handlers? table<string, render.md.Handler>

---@private
---@type render.md.Config
M.default_config = {
    -- Whether Markdown should be rendered by default or not
    enabled = true,
    -- Maximum file size (in MB) that this plugin will attempt to render
    -- Any file larger than this will effectively be ignored
    max_file_size = 10.0,
    -- Milliseconds that must pass before updating marks, updates occur
    -- within the context of the visible window, not the entire buffer
    debounce = 100,
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

        (shortcut_link) @shortcut

        [(inline_link) (full_reference_link) (image)] @link
    ]],
    -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'
    -- Only intended to be used for plugin development / debugging
    log_level = 'error',
    -- Filetypes this plugin will run on
    file_types = { 'markdown' },
    -- Vim modes that will show a rendered view of the markdown file
    -- All other modes will be uneffected by this plugin
    render_modes = { 'n', 'c' },
    -- Set to avoid seeing warnings for conflicts in health check
    acknowledge_conflicts = false,
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
        -- Amount of empty lines above LaTeX blocks
        top_pad = 0,
        -- Amount of empty lines below LaTeX blocks
        bottom_pad = 0,
    },
    heading = {
        -- Turn on / off heading icon & background rendering
        enabled = true,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Determines how the icon fills the available space:
        --  inline: underlying '#'s are concealed resulting in a left aligned icon
        --  overlay: result is left padded with spaces to hide any additional '#'
        position = 'overlay',
        -- Replaces '#+' of 'atx_h._marker'
        -- The number of '#' in the heading determines the 'level'
        -- The 'level' is used to index into the array using a cycle
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        -- Added to the sign column if enabled
        -- The 'level' is used to index into the array using a cycle
        signs = { '󰫎 ' },
        -- Width of the heading background:
        --  block: width of the heading text
        --  full: full width of the window
        width = 'full',
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
        -- Determines where language icon is rendered:
        --  right: Right side of code block
        --  left: Left side of code block
        position = 'left',
        -- An array of language names for which background highlighting will be disabled
        -- Likely because that language has background highlights itself
        disable_background = { 'diff' },
        -- Amount of padding to add to the left of code blocks
        left_pad = 0,
        -- Amount of padding to add to the right of code blocks when width is 'block'
        right_pad = 0,
        -- Width of the code block background:
        --  block: width of the code block
        --  full: full width of the window
        width = 'full',
        -- Determins how the top / bottom of code block are rendered:
        --  thick: use the same highlight as the code body
        --  thin: when lines are empty overlay the above & below icons
        border = 'thin',
        -- Used above code blocks for thin border
        above = '▄',
        -- Used below code blocks for thin border
        below = '▀',
        -- Highlight for code blocks
        highlight = 'RenderMarkdownCode',
        -- Highlight for inline code
        highlight_inline = 'RenderMarkdownCodeInline',
    },
    dash = {
        -- Turn on / off thematic break rendering
        enabled = true,
        -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'
        -- The icon gets repeated across the window's width
        icon = '─',
        -- Width of the generated line:
        --  <integer>: a hard coded width value
        --  full: full width of the window
        width = 'full',
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
        -- Padding to add to the right of bullet point
        right_pad = 0,
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
        -- Whether to repeat icon on wrapped lines. Requires neovim >= 0.10. This will obscure text if
        -- not configured correctly with :h 'showbreak', :h 'breakindent' and :h 'breakindentopt'. A
        -- combination of these that is likely to work is showbreak = '  ' (2 spaces), breakindent = true,
        -- breakindentopt = '' (empty string). These values are not validated by this plugin. If you want
        -- to avoid adding these to your main configuration then set them in win_options for this plugin.
        repeat_linebreak = false,
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
        -- Gets placed in delimiter row for each column, position is based on alignmnet
        alignment_indicator = '━',
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
        -- Fallback icon for 'inline_link' elements
        hyperlink = '󰌹 ',
        -- Applies to the fallback inlined icon
        highlight = 'RenderMarkdownLink',
        -- Define custom destination patterns so icons can quickly inform you of what a link
        -- contains. Applies to 'inline_link' and wikilink nodes.
        -- Can specify as many additional values as you like following the 'web' pattern below
        --   The key in this case 'web' is for healthcheck and to allow users to change its values
        --   'pattern': Matched against the destination text see :h lua-pattern
        --   'icon': Gets inlined before the link text
        --   'highlight': Highlight for the 'icon'
        custom = {
            web = { pattern = '^http[s]?://', icon = '󰖟 ', highlight = 'RenderMarkdownLink' },
        },
    },
    sign = {
        -- Turn on / off sign rendering
        enabled = true,
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
    -- More granular configuration mechanism, allows different aspects of buffers
    -- to have their own behavior. Values default to the top level configuration
    -- if no override is provided. Supports the following fields:
    --   enabled, max_file_size, debounce, render_modes, anti_conceal, heading, code,
    --   dash, bullet, checkbox, quote, pipe_table, callout, link, sign, win_options
    overrides = {
        -- Overrides for different buftypes, see :h 'buftype'
        buftype = {
            nofile = {
                sign = { enabled = false },
            },
        },
    },
    -- Mapping from treesitter language to user defined handlers
    -- See 'Custom Handlers' document for more info
    custom_handlers = {},
}

---@param opts? render.md.UserConfig
function M.setup(opts)
    -- This handles discrepancies in initialization order of different plugin managers, some
    -- run the plugin directory first (lazy.nvim) while others run setup first (vim-plug).
    -- To support both we want to pickup the last non-empty configuration. This works because
    -- the plugin directory supplies an empty configuration which will be skipped if state
    -- has already been initialized by the user.
    local state = require('render-markdown.state')
    if not state.initialized() or vim.tbl_count(opts or {}) > 0 then
        state.setup(M.default_config, opts)
        state.invalidate_cache()
        require('render-markdown.ui').invalidate_cache()
    end
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('render-markdown.api')[key]
    end,
})
