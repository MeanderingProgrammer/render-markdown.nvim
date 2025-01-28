---@class render.md.Init: render.md.Api
local M = {}

---@class (exact) render.md.Mark
---@field public conceal boolean
---@field public start_row integer
---@field public start_col integer
---@field public opts vim.api.keyset.set_extmark

---@class (exact) render.md.Handler
---@field public extends? boolean
---@field public parse fun(root: TSNode, buf: integer): render.md.Mark[]

---@class (exact) render.md.UserCallback
---@field public attach? fun(buf: integer)
---@field public render? fun(buf: integer)

---@class (exact) render.md.UserInjection
---@field public enabled? boolean
---@field public query? string

---@alias render.md.option.Value number|integer|string|boolean

---@class (exact) render.md.UserWindowOption
---@field public default? render.md.option.Value
---@field public rendered? render.md.option.Value

---@class (exact) render.md.UserBaseComponent
---@field public enabled? boolean
---@field public render_modes? render.md.Modes

---@class (exact) render.md.UserHtmlComment
---@field public conceal? boolean
---@field public text? string
---@field public highlight? string

---@class (exact) render.md.UserHtml: render.md.UserBaseComponent
---@field public comment? render.md.UserHtmlComment

---@class (exact) render.md.UserLatex: render.md.UserBaseComponent
---@field public converter? string
---@field public highlight? string
---@field public top_pad? integer
---@field public bottom_pad? integer

---@class (exact) render.md.UserIndent: render.md.UserBaseComponent
---@field public per_level? integer
---@field public skip_level? integer
---@field public skip_heading? boolean

---@class (exact) render.md.UserInlineHighlight: render.md.UserBaseComponent
---@field public highlight? string

---@class (exact) render.md.UserSign
---@field public enabled? boolean
---@field public highlight? string

---@class (exact) render.md.UserLinkComponent
---@field public pattern? string
---@field public icon? string
---@field public highlight? string

---@class (exact) render.md.UserWikiLink
---@field public icon? string
---@field public highlight? string

---@class (exact) render.md.UserFootnote
---@field public superscript? boolean
---@field public prefix? string
---@field public suffix? string

---@class (exact) render.md.UserLink: render.md.UserBaseComponent
---@field public footnote? render.md.UserFootnote
---@field public image? string
---@field public email? string
---@field public hyperlink? string
---@field public highlight? string
---@field public wiki? render.md.UserWikiLink
---@field public custom? table<string, render.md.UserLinkComponent>

---@class (exact) render.md.UserCustomCallout
---@field public raw? string
---@field public rendered? string
---@field public highlight? string
---@field public quote_icon? string

---@alias render.md.table.Preset 'none'|'round'|'double'|'heavy'
---@alias render.md.table.Style 'full'|'normal'|'none'
---@alias render.md.table.Cell 'trimmed'|'padded'|'raw'|'overlay'

---@class (exact) render.md.UserPipeTable: render.md.UserBaseComponent
---@field public preset? render.md.table.Preset
---@field public style? render.md.table.Style
---@field public cell? render.md.table.Cell
---@field public padding? integer
---@field public min_width? integer
---@field public border? string[]
---@field public alignment_indicator? string
---@field public head? string
---@field public row? string
---@field public filler? string

---@class (exact) render.md.UserQuote: render.md.UserBaseComponent
---@field public icon? string
---@field public repeat_linebreak? boolean
---@field public highlight? string

---@class (exact) render.md.UserCustomCheckbox
---@field public raw? string
---@field public rendered? string
---@field public highlight? string
---@field public scope_highlight? string

---@class (exact) render.md.UserCheckboxComponent
---@field public icon? string
---@field public highlight? string
---@field public scope_highlight? string

---@alias render.md.checkbox.Position 'overlay'|'inline'

---@class (exact) render.md.UserCheckbox: render.md.UserBaseComponent
---@field public position? render.md.checkbox.Position
---@field public unchecked? render.md.UserCheckboxComponent
---@field public checked? render.md.UserCheckboxComponent
---@field public custom? table<string, render.md.UserCustomCheckbox>

---@alias render.md.bullet.Icons
---| string[]
---| string[][]
---| fun(level: integer, index: integer, value: string): string?

---@class (exact) render.md.UserBullet: render.md.UserBaseComponent
---@field public icons? render.md.bullet.Icons
---@field public ordered_icons? render.md.bullet.Icons
---@field public left_pad? integer
---@field public right_pad? integer
---@field public highlight? string

---@class (exact) render.md.UserDash: render.md.UserBaseComponent
---@field public icon? string
---@field public width? 'full'|number
---@field public left_margin? number
---@field public highlight? string

---@alias render.md.code.Style 'full'|'normal'|'language'|'none'
---@alias render.md.code.Position 'left'|'right'
---@alias render.md.code.Width 'full'|'block'
---@alias render.md.code.Border 'thin'|'thick'|'none'

---@class (exact) render.md.UserCode: render.md.UserBaseComponent
---@field public sign? boolean
---@field public style? render.md.code.Style
---@field public position? render.md.code.Position
---@field public language_pad? number
---@field public language_name? boolean
---@field public disable_background? boolean|string[]
---@field public width? render.md.code.Width
---@field public left_margin? number
---@field public left_pad? number
---@field public right_pad? number
---@field public min_width? integer
---@field public border? render.md.code.Border
---@field public above? string
---@field public below? string
---@field public highlight? string
---@field public highlight_language? string
---@field public inline_pad? integer
---@field public highlight_inline? string

---@class (exact) render.md.UserParagraph: render.md.UserBaseComponent
---@field public left_margin? number
---@field public min_width? integer

---@alias render.md.heading.Icons
---| string[]
---| fun(sections: integer[]): string?
---@alias render.md.heading.Position 'overlay'|'inline'|'right'
---@alias render.md.heading.Width 'full'|'block'

---@class (exact) render.md.UserHeading: render.md.UserBaseComponent
---@field public sign? boolean
---@field public icons? render.md.heading.Icons
---@field public position? render.md.heading.Position
---@field public signs? string[]
---@field public width? render.md.heading.Width|(render.md.heading.Width)[]
---@field public left_margin? number|number[]
---@field public left_pad? number|number[]
---@field public right_pad? number|number[]
---@field public min_width? integer|integer[]
---@field public border? boolean|boolean[]
---@field public border_virtual? boolean
---@field public border_prefix? boolean
---@field public above? string
---@field public below? string
---@field public backgrounds? string[]
---@field public foregrounds? string[]

---@class (exact) render.md.UserPadding
---@field public highlight? string

---@alias render.md.Element
---| 'head_icon'
---| 'head_background'
---| 'head_border'
---| 'code_language'
---| 'code_background'
---| 'code_border'
---| 'dash'
---| 'bullet'
---| 'check_icon'
---| 'check_scope'
---| 'quote'
---| 'table_border'
---| 'callout'
---| 'link'
---| 'sign'

---@alias render.md.config.conceal.Ignore table<render.md.Element, render.md.Modes>

---@class (exact) render.md.UserAntiConceal
---@field public enabled? boolean
---@field public ignore? render.md.config.conceal.Ignore
---@field public above? integer
---@field public below? integer

---@class (exact) render.md.UserConfigOverrides
---@field public buflisted? table<boolean, render.md.UserBufferConfig>
---@field public buftype? table<string, render.md.UserBufferConfig>
---@field public filetype? table<string, render.md.UserBufferConfig>

---@alias render.md.Modes boolean|string[]

---@class (exact) render.md.UserBufferConfig
---@field public enabled? boolean
---@field public render_modes? render.md.Modes
---@field public max_file_size? number
---@field public debounce? integer
---@field public anti_conceal? render.md.UserAntiConceal
---@field public padding? render.md.UserPadding
---@field public heading? render.md.UserHeading
---@field public paragraph? render.md.UserParagraph
---@field public code? render.md.UserCode
---@field public dash? render.md.UserDash
---@field public bullet? render.md.UserBullet
---@field public checkbox? render.md.UserCheckbox
---@field public quote? render.md.UserQuote
---@field public pipe_table? render.md.UserPipeTable
---@field public callout? table<string, render.md.UserCustomCallout>
---@field public link? render.md.UserLink
---@field public sign? render.md.UserSign
---@field public inline_highlight? render.md.UserInlineHighlight
---@field public indent? render.md.UserIndent
---@field public latex? render.md.UserLatex
---@field public html? render.md.UserHtml
---@field public win_options? table<string, render.md.UserWindowOption>

---@alias render.md.config.Preset 'none'|'lazy'|'obsidian'
---@alias render.md.config.LogLevel 'off'|'debug'|'info'|'error'

---@class (exact) render.md.UserConfig: render.md.UserBufferConfig
---@field public preset? render.md.config.Preset
---@field public log_level? render.md.config.LogLevel
---@field public log_runtime? boolean
---@field public file_types? string[]
---@field public injections? table<string, render.md.UserInjection>
---@field public on? render.md.UserCallback
---@field public overrides? render.md.UserConfigOverrides
---@field public custom_handlers? table<string, render.md.Handler>

---@type render.md.Config
M.default_config = {
    -- Whether Markdown should be rendered by default or not
    enabled = true,
    -- Vim modes that will show a rendered view of the markdown file, :h mode(), for
    -- all enabled components. Individual components can be enabled for other modes.
    -- Remaining modes will be unaffected by this plugin.
    render_modes = { 'n', 'c', 't' },
    -- Maximum file size (in MB) that this plugin will attempt to render
    -- Any file larger than this will effectively be ignored
    max_file_size = 10.0,
    -- Milliseconds that must pass before updating marks, updates occur
    -- within the context of the visible window, not the entire buffer
    debounce = 100,
    -- Pre configured settings that will attempt to mimic various target
    -- user experiences. Any user provided settings will take precedence.
    --  obsidian: mimic Obsidian UI
    --  lazy:     will attempt to stay up to date with LazyVim configuration
    --  none:     does nothing
    preset = 'none',
    -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'
    -- Only intended to be used for plugin development / debugging
    log_level = 'error',
    -- Print runtime of main update method
    -- Only intended to be used for plugin development / debugging
    log_runtime = false,
    -- Filetypes this plugin will run on
    file_types = { 'markdown' },
    -- Out of the box language injections for known filetypes that allow markdown to be
    -- interpreted in specified locations, see :h treesitter-language-injections
    -- Set enabled to false in order to disable
    injections = {
        gitcommit = {
            enabled = true,
            query = [[
                ((message) @injection.content
                    (#set! injection.combined)
                    (#set! injection.include-children)
                    (#set! injection.language "markdown"))
            ]],
        },
    },
    anti_conceal = {
        -- This enables hiding any added text on the line the cursor is on
        enabled = true,
        -- Which elements to always show, ignoring anti conceal behavior. Values can either be booleans
        -- to fix the behavior or string lists representing modes where anti conceal behavior will be
        -- ignored. Possible keys are:
        --  head_icon, head_background, head_border, code_language, code_background, code_border
        --  dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
        ignore = {
            code_background = true,
            sign = true,
        },
        -- Number of lines above cursor to show
        above = 0,
        -- Number of lines below cursor to show
        below = 0,
    },
    padding = {
        -- Highlight to use when adding whitespace, should match background
        highlight = 'Normal',
    },
    latex = {
        -- Whether LaTeX should be rendered, mainly used for health check
        enabled = true,
        -- Additional modes to render LaTeX
        render_modes = false,
        -- Executable used to convert latex formula to rendered unicode
        converter = 'latex2text',
        -- Highlight for LaTeX blocks
        highlight = 'RenderMarkdownMath',
        -- Amount of empty lines above LaTeX blocks
        top_pad = 0,
        -- Amount of empty lines below LaTeX blocks
        bottom_pad = 0,
    },
    on = {
        -- Called when plugin initially attaches to a buffer
        attach = function() end,
        -- Called after plugin renders a buffer
        render = function() end,
    },
    heading = {
        -- Turn on / off heading icon & background rendering
        enabled = true,
        -- Additional modes to render headings
        render_modes = false,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Replaces '#+' of 'atx_h._marker'
        -- The number of '#' in the heading determines the 'level'
        -- The 'level' is used to index into the list using a cycle
        -- If the value is a function the input is the nesting level of the heading within sections
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        -- Determines how icons fill the available space:
        --  right:   '#'s are concealed and icon is appended to right side
        --  inline:  '#'s are concealed and icon is inlined on left side
        --  overlay: icon is left padded with spaces and inserted on left hiding any additional '#'
        position = 'overlay',
        -- Added to the sign column if enabled
        -- The 'level' is used to index into the list using a cycle
        signs = { '󰫎 ' },
        -- Width of the heading background:
        --  block: width of the heading text
        --  full:  full width of the window
        -- Can also be a list of the above values in which case the 'level' is used
        -- to index into the list using a clamp
        width = 'full',
        -- Amount of margin to add to the left of headings
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        -- Margin available space is computed after accounting for padding
        -- Can also be a list of numbers in which case the 'level' is used to index into the list using a clamp
        left_margin = 0,
        -- Amount of padding to add to the left of headings
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        -- Can also be a list of numbers in which case the 'level' is used to index into the list using a clamp
        left_pad = 0,
        -- Amount of padding to add to the right of headings when width is 'block'
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        -- Can also be a list of numbers in which case the 'level' is used to index into the list using a clamp
        right_pad = 0,
        -- Minimum width to use for headings when width is 'block'
        -- Can also be a list of integers in which case the 'level' is used to index into the list using a clamp
        min_width = 0,
        -- Determines if a border is added above and below headings
        -- Can also be a list of booleans in which case the 'level' is used to index into the list using a clamp
        border = false,
        -- Always use virtual lines for heading borders instead of attempting to use empty lines
        border_virtual = false,
        -- Highlight the start of the border using the foreground highlight
        border_prefix = false,
        -- Used above heading for border
        above = '▄',
        -- Used below heading for border
        below = '▀',
        -- The 'level' is used to index into the list using a clamp
        -- Highlight for the heading icon and extends through the entire line
        backgrounds = {
            'RenderMarkdownH1Bg',
            'RenderMarkdownH2Bg',
            'RenderMarkdownH3Bg',
            'RenderMarkdownH4Bg',
            'RenderMarkdownH5Bg',
            'RenderMarkdownH6Bg',
        },
        -- The 'level' is used to index into the list using a clamp
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
    paragraph = {
        -- Turn on / off paragraph rendering
        enabled = true,
        -- Additional modes to render paragraphs
        render_modes = false,
        -- Amount of margin to add to the left of paragraphs
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        left_margin = 0,
        -- Minimum width to use for paragraphs
        min_width = 0,
    },
    code = {
        -- Turn on / off code block & inline code rendering
        enabled = true,
        -- Additional modes to render code blocks
        render_modes = false,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Determines how code blocks & inline code are rendered:
        --  none:     disables all rendering
        --  normal:   adds highlight group to code blocks & inline code, adds padding to code blocks
        --  language: adds language icon to sign column if enabled and icon + name above code blocks
        --  full:     normal + language
        style = 'full',
        -- Determines where language icon is rendered:
        --  right: right side of code block
        --  left:  left side of code block
        position = 'left',
        -- Amount of padding to add around the language
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        language_pad = 0,
        -- Whether to include the language name next to the icon
        language_name = true,
        -- A list of language names for which background highlighting will be disabled
        -- Likely because that language has background highlights itself
        -- Or a boolean to make behavior apply to all languages
        -- Borders above & below blocks will continue to be rendered
        disable_background = { 'diff' },
        -- Width of the code block background:
        --  block: width of the code block
        --  full:  full width of the window
        width = 'full',
        -- Amount of margin to add to the left of code blocks
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        -- Margin available space is computed after accounting for padding
        left_margin = 0,
        -- Amount of padding to add to the left of code blocks
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        left_pad = 0,
        -- Amount of padding to add to the right of code blocks when width is 'block'
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        right_pad = 0,
        -- Minimum width to use for code blocks when width is 'block'
        min_width = 0,
        -- Determines how the top / bottom of code block are rendered:
        --  none:  do not render a border
        --  thick: use the same highlight as the code body
        --  thin:  when lines are empty overlay the above & below icons
        border = 'thin',
        -- Used above code blocks for thin border
        above = '▄',
        -- Used below code blocks for thin border
        below = '▀',
        -- Highlight for code blocks
        highlight = 'RenderMarkdownCode',
        -- Highlight for language, overrides icon provider value
        highlight_language = nil,
        -- Padding to add to the left & right of inline code
        inline_pad = 0,
        -- Highlight for inline code
        highlight_inline = 'RenderMarkdownCodeInline',
    },
    dash = {
        -- Turn on / off thematic break rendering
        enabled = true,
        -- Additional modes to render dash
        render_modes = false,
        -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'
        -- The icon gets repeated across the window's width
        icon = '─',
        -- Width of the generated line:
        --  <number>: a hard coded width value, if a floating point value < 1 is provided it is
        --            treated as a percentage of the available window space
        --  full:     full width of the window
        width = 'full',
        -- Amount of margin to add to the left of dash
        -- If a floating point value < 1 is provided it is treated as a percentage of the available window space
        left_margin = 0,
        -- Highlight for the whole line generated from the icon
        highlight = 'RenderMarkdownDash',
    },
    bullet = {
        -- Turn on / off list bullet rendering
        enabled = true,
        -- Additional modes to render list bullets
        render_modes = false,
        -- Replaces '-'|'+'|'*' of 'list_item'
        -- How deeply nested the list is determines the 'level', how far down at that level determines the 'index'
        -- If a function is provided both of these values are passed in using 1 based indexing
        -- If a list is provided we index into it using a cycle based on the level
        -- If the value at that level is also a list we further index into it using a clamp based on the index
        -- If the item is a 'checkbox' a conceal is used to hide the bullet instead
        icons = { '●', '○', '◆', '◇' },
        -- Replaces 'n.'|'n)' of 'list_item'
        -- How deeply nested the list is determines the 'level', how far down at that level determines the 'index'
        -- If a function is provided both of these values are passed in using 1 based indexing
        -- If a list is provided we index into it using a cycle based on the level
        -- If the value at that level is also a list we further index into it using a clamp based on the index
        ordered_icons = function(level, index, value)
            value = vim.trim(value)
            local value_index = tonumber(value:sub(1, #value - 1))
            return string.format('%d.', value_index > 1 and value_index or index)
        end,
        -- Padding to add to the left of bullet point
        left_pad = 0,
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
        -- Additional modes to render checkboxes
        render_modes = false,
        -- Determines how icons fill the available space:
        --  inline:  underlying text is concealed resulting in a left aligned icon
        --  overlay: result is left padded with spaces to hide any additional text
        position = 'inline',
        unchecked = {
            -- Replaces '[ ]' of 'task_list_marker_unchecked'
            icon = '󰄱 ',
            -- Highlight for the unchecked icon
            highlight = 'RenderMarkdownUnchecked',
            -- Highlight for item associated with unchecked checkbox
            scope_highlight = nil,
        },
        checked = {
            -- Replaces '[x]' of 'task_list_marker_checked'
            icon = '󰱒 ',
            -- Highlight for the checked icon
            highlight = 'RenderMarkdownChecked',
            -- Highlight for item associated with checked checkbox
            scope_highlight = nil,
        },
        -- Define custom checkbox states, more involved as they are not part of the markdown grammar
        -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks
        -- Can specify as many additional states as you like following the 'todo' pattern below
        --   The key in this case 'todo' is for healthcheck and to allow users to change its values
        --   'raw':             Matched against the raw text of a 'shortcut_link'
        --   'rendered':        Replaces the 'raw' value when rendering
        --   'highlight':       Highlight for the 'rendered' icon
        --   'scope_highlight': Highlight for item associated with custom checkbox
        custom = {
            todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
        },
    },
    quote = {
        -- Turn on / off block quote & callout rendering
        enabled = true,
        -- Additional modes to render quotes
        render_modes = false,
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
        -- Additional modes to render pipe tables
        render_modes = false,
        -- Pre configured settings largely for setting table border easier
        --  heavy:  use thicker border characters
        --  double: use double line border characters
        --  round:  use round border corners
        --  none:   does nothing
        preset = 'none',
        -- Determines how the table as a whole is rendered:
        --  none:   disables all rendering
        --  normal: applies the 'cell' style rendering to each row of the table
        --  full:   normal + a top & bottom line that fill out the table when lengths match
        style = 'full',
        -- Determines how individual cells of a table are rendered:
        --  overlay: writes completely over the table, removing conceal behavior and highlights
        --  raw:     replaces only the '|' characters in each row, leaving the cells unmodified
        --  padded:  raw + cells are padded to maximum visual width for each column
        --  trimmed: padded except empty space is subtracted from visual width calculation
        cell = 'padded',
        -- Amount of space to put between cell contents and border
        padding = 1,
        -- Minimum column width to use for padded or trimmed cell
        min_width = 0,
        -- Characters used to replace table border
        -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal
        -- stylua: ignore
        border = {
            '┌', '┬', '┐',
            '├', '┼', '┤',
            '└', '┴', '┘',
            '│', '─',
        },
        -- Gets placed in delimiter row for each column, position is based on alignment
        alignment_indicator = '━',
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
    --   'raw':        Matched against the raw text of a 'shortcut_link', case insensitive
    --   'rendered':   Replaces the 'raw' value when rendering
    --   'highlight':  Highlight for the 'rendered' text and quote markers
    --   'quote_icon': Optional override for quote.icon value for individual callout
    callout = {
        note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
        tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
        important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint' },
        warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
        caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
        -- Obsidian: https://help.obsidian.md/Editing+and+formatting/Callouts
        abstract = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo' },
        summary = { raw = '[!SUMMARY]', rendered = '󰨸 Summary', highlight = 'RenderMarkdownInfo' },
        tldr = { raw = '[!TLDR]', rendered = '󰨸 Tldr', highlight = 'RenderMarkdownInfo' },
        info = { raw = '[!INFO]', rendered = '󰋽 Info', highlight = 'RenderMarkdownInfo' },
        todo = { raw = '[!TODO]', rendered = '󰗡 Todo', highlight = 'RenderMarkdownInfo' },
        hint = { raw = '[!HINT]', rendered = '󰌶 Hint', highlight = 'RenderMarkdownSuccess' },
        success = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess' },
        check = { raw = '[!CHECK]', rendered = '󰄬 Check', highlight = 'RenderMarkdownSuccess' },
        done = { raw = '[!DONE]', rendered = '󰄬 Done', highlight = 'RenderMarkdownSuccess' },
        question = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn' },
        help = { raw = '[!HELP]', rendered = '󰘥 Help', highlight = 'RenderMarkdownWarn' },
        faq = { raw = '[!FAQ]', rendered = '󰘥 Faq', highlight = 'RenderMarkdownWarn' },
        attention = { raw = '[!ATTENTION]', rendered = '󰀪 Attention', highlight = 'RenderMarkdownWarn' },
        failure = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError' },
        fail = { raw = '[!FAIL]', rendered = '󰅖 Fail', highlight = 'RenderMarkdownError' },
        missing = { raw = '[!MISSING]', rendered = '󰅖 Missing', highlight = 'RenderMarkdownError' },
        danger = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError' },
        error = { raw = '[!ERROR]', rendered = '󱐌 Error', highlight = 'RenderMarkdownError' },
        bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError' },
        example = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint' },
        quote = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote' },
        cite = { raw = '[!CITE]', rendered = '󱆨 Cite', highlight = 'RenderMarkdownQuote' },
    },
    link = {
        -- Turn on / off inline link icon rendering
        enabled = true,
        -- Additional modes to render links
        render_modes = false,
        -- How to handle footnote links, start with a '^'
        footnote = {
            -- Replace value with superscript equivalent
            superscript = true,
            -- Added before link content when converting to superscript
            prefix = '',
            -- Added after link content when converting to superscript
            suffix = '',
        },
        -- Inlined with 'image' elements
        image = '󰥶 ',
        -- Inlined with 'email_autolink' elements
        email = '󰀓 ',
        -- Fallback icon for 'inline_link' and 'uri_autolink' elements
        hyperlink = '󰌹 ',
        -- Applies to the inlined icon as a fallback
        highlight = 'RenderMarkdownLink',
        -- Applies to WikiLink elements
        wiki = { icon = '󱗖 ', highlight = 'RenderMarkdownWikiLink' },
        -- Define custom destination patterns so icons can quickly inform you of what a link
        -- contains. Applies to 'inline_link', 'uri_autolink', and wikilink nodes. When multiple
        -- patterns match a link the one with the longer pattern is used.
        -- Can specify as many additional values as you like following the 'web' pattern below
        --   The key in this case 'web' is for healthcheck and to allow users to change its values
        --   'pattern':   Matched against the destination text see :h lua-pattern
        --   'icon':      Gets inlined before the link text
        --   'highlight': Optional highlight for the 'icon', uses fallback highlight if not provided
        custom = {
            web = { pattern = '^http', icon = '󰖟 ' },
            discord = { pattern = 'discord%.com', icon = '󰙯 ' },
            github = { pattern = 'github%.com', icon = '󰊤 ' },
            gitlab = { pattern = 'gitlab%.com', icon = '󰮠 ' },
            google = { pattern = 'google%.com', icon = '󰊭 ' },
            neovim = { pattern = 'neovim%.io', icon = ' ' },
            reddit = { pattern = 'reddit%.com', icon = '󰑍 ' },
            stackoverflow = { pattern = 'stackoverflow%.com', icon = '󰓌 ' },
            wikipedia = { pattern = 'wikipedia%.org', icon = '󰖬 ' },
            youtube = { pattern = 'youtube%.com', icon = '󰗃 ' },
        },
    },
    sign = {
        -- Turn on / off sign rendering
        enabled = true,
        -- Applies to background of sign text
        highlight = 'RenderMarkdownSign',
    },
    -- Mimics Obsidian inline highlights when content is surrounded by double equals
    -- The equals on both ends are concealed and the inner content is highlighted
    inline_highlight = {
        -- Turn on / off inline highlight rendering
        enabled = true,
        -- Additional modes to render inline highlights
        render_modes = false,
        -- Applies to background of surrounded text
        highlight = 'RenderMarkdownInlineHighlight',
    },
    -- Mimic org-indent-mode behavior by indenting everything under a heading based on the
    -- level of the heading. Indenting starts from level 2 headings onward.
    indent = {
        -- Turn on / off org-indent-mode
        enabled = false,
        -- Additional modes to render indents
        render_modes = false,
        -- Amount of additional padding added for each heading level
        per_level = 2,
        -- Heading levels <= this value will not be indented
        -- Use 0 to begin indenting from the very first level
        skip_level = 1,
        -- Do not indent heading titles, only the body
        skip_heading = false,
    },
    html = {
        -- Turn on / off all HTML rendering
        enabled = true,
        -- Additional modes to render HTML
        render_modes = false,
        comment = {
            -- Turn on / off HTML comment concealing
            conceal = true,
            -- Optional text to inline before the concealed comment
            text = nil,
            -- Highlight for the inlined text
            highlight = 'RenderMarkdownHtmlComment',
        },
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
    --   enabled, max_file_size, debounce, render_modes, anti_conceal, padding,
    --   heading, paragraph, code, dash, bullet, checkbox, quote, pipe_table,
    --   callout, link, sign, indent, latex, html, win_options
    overrides = {
        -- Override for different buflisted values, see :h 'buflisted'
        buflisted = {},
        -- Override for different buftype values, see :h 'buftype'
        buftype = {
            nofile = {
                padding = { highlight = 'NormalFloat' },
                sign = { enabled = false },
            },
        },
        -- Override for different filetype values, see :h 'filetype'
        filetype = {},
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
        state.setup(M.default_config, opts or {})
        state.invalidate_cache()
        require('render-markdown.core.ui').invalidate_cache()
    end
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('render-markdown.api')[key]
    end,
})
