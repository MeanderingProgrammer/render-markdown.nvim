---@class render.md.Init: render.md.Api
local M = {}

---@class (exact) render.md.Handler
---@field extends? boolean
---@field parse fun(ctx: render.md.HandlerContext): render.md.Mark[]

---@class (exact) render.md.HandlerContext
---@field buf integer
---@field root TSNode

---@class (exact) render.md.Mark
---@field conceal boolean
---@field start_row integer
---@field start_col integer
---@field opts render.md.MarkOpts

---@class render.md.MarkOpts: vim.api.keyset.set_extmark
---@field virt_text? render.md.MarkLine
---@field virt_text_pos? 'eol'|'inline'|'overlay'
---@field virt_lines? render.md.MarkLine[]

---@alias render.md.MarkLine render.md.MarkText[]

---@class (exact) render.md.MarkText
---@field [1] string text
---@field [2] string|string[] highlights

---@class (exact) render.md.UserBufferConfig
---@field enabled? boolean
---@field render_modes? render.md.Modes
---@field max_file_size? number
---@field debounce? integer
---@field anti_conceal? render.md.UserAntiConceal
---@field padding? render.md.UserPadding
---@field heading? render.md.UserHeading
---@field paragraph? render.md.UserParagraph
---@field code? render.md.UserCode
---@field dash? render.md.UserDash
---@field bullet? render.md.UserBullet
---@field checkbox? render.md.UserCheckbox
---@field quote? render.md.UserQuote
---@field pipe_table? render.md.UserPipeTable
---@field callout? table<string, render.md.UserCustomCallout>
---@field link? render.md.UserLink
---@field sign? render.md.UserSign
---@field inline_highlight? render.md.UserInlineHighlight
---@field indent? render.md.UserIndent
---@field latex? render.md.UserLatex
---@field html? render.md.UserHtml
---@field win_options? table<string, render.md.UserWindowOption>

---@alias render.md.Modes boolean|string[]

---@class (exact) render.md.UserAntiConceal
---@field enabled? boolean
---@field ignore? render.md.config.conceal.Ignore
---@field above? integer
---@field below? integer

---@alias render.md.config.conceal.Ignore table<render.md.Element, render.md.Modes>

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

---@class (exact) render.md.UserPadding
---@field highlight? string

---@class (exact) render.md.UserBaseComponent
---@field enabled? boolean
---@field render_modes? render.md.Modes

---@class (exact) render.md.UserHeading: render.md.UserBaseComponent
---@field atx? boolean
---@field setext? boolean
---@field sign? boolean
---@field icons? render.md.heading.Icons
---@field position? render.md.heading.Position
---@field signs? string[]
---@field width? render.md.heading.Width|(render.md.heading.Width)[]
---@field left_margin? number|number[]
---@field left_pad? number|number[]
---@field right_pad? number|number[]
---@field min_width? integer|integer[]
---@field border? boolean|boolean[]
---@field border_virtual? boolean
---@field border_prefix? boolean
---@field above? string
---@field below? string
---@field backgrounds? string[]
---@field foregrounds? string[]
---@field custom? table<string, render.md.HeadingCustom>

---@alias render.md.heading.Icons
---| string[]
---| fun(ctx: render.md.HeadingContext): string?

---@alias render.md.heading.Position 'overlay'|'inline'|'right'

---@alias render.md.heading.Width 'full'|'block'

---@class (exact) render.md.HeadingContext
---@field level integer
---@field sections integer[]

---@class (exact) render.md.HeadingCustom
---@field pattern string
---@field icon? string
---@field background? string
---@field foreground? string

---@class (exact) render.md.UserParagraph: render.md.UserBaseComponent
---@field left_margin? number
---@field min_width? integer

---@class (exact) render.md.UserCode: render.md.UserBaseComponent
---@field sign? boolean
---@field style? render.md.code.Style
---@field position? render.md.code.Position
---@field language_pad? number
---@field language_icon? boolean
---@field language_name? boolean
---@field disable_background? boolean|string[]
---@field width? render.md.code.Width
---@field left_margin? number
---@field left_pad? number
---@field right_pad? number
---@field min_width? integer
---@field border? render.md.code.Border
---@field above? string
---@field below? string
---@field inline_left? string
---@field inline_right? string
---@field inline_pad? integer
---@field highlight? string
---@field highlight_language? string
---@field highlight_border? string|boolean
---@field highlight_fallback? string
---@field highlight_inline? string

---@alias render.md.code.Style 'full'|'normal'|'language'|'none'

---@alias render.md.code.Position 'left'|'right'

---@alias render.md.code.Width 'full'|'block'

---@alias render.md.code.Border 'hide'|'thin'|'thick'|'none'

---@class (exact) render.md.UserDash: render.md.UserBaseComponent
---@field icon? string
---@field width? 'full'|number
---@field left_margin? number
---@field highlight? string

---@class (exact) render.md.UserBullet: render.md.UserBaseComponent
---@field icons? render.md.bullet.Text
---@field ordered_icons? render.md.bullet.Text
---@field left_pad? render.md.bullet.Int
---@field right_pad? render.md.bullet.Int
---@field highlight? render.md.bullet.Text
---@field scope_highlight? render.md.bullet.Text

---@alias render.md.bullet.Text
---| string
---| string[]
---| string[][]
---| fun(ctx: render.md.BulletContext): string?

---@alias render.md.bullet.Int
---| integer
---| fun(ctx: render.md.BulletContext): integer

---@class (exact) render.md.BulletContext
---@field level integer
---@field index integer
---@field value string

---@class (exact) render.md.UserCheckbox: render.md.UserBaseComponent
---@field right_pad? integer
---@field unchecked? render.md.UserCheckboxComponent
---@field checked? render.md.UserCheckboxComponent
---@field custom? table<string, render.md.UserCustomCheckbox>

---@class (exact) render.md.UserCheckboxComponent
---@field icon? string
---@field highlight? string
---@field scope_highlight? string

---@class (exact) render.md.UserCustomCheckbox
---@field raw? string
---@field rendered? string
---@field highlight? string
---@field scope_highlight? string

---@class (exact) render.md.UserQuote: render.md.UserBaseComponent
---@field icon? string
---@field repeat_linebreak? boolean
---@field highlight? string

---@class (exact) render.md.UserPipeTable: render.md.UserBaseComponent
---@field preset? render.md.table.Preset
---@field style? render.md.table.Style
---@field cell? render.md.table.Cell
---@field padding? integer
---@field min_width? integer
---@field border? string[]
---@field alignment_indicator? string
---@field head? string
---@field row? string
---@field filler? string

---@alias render.md.table.Preset 'none'|'round'|'double'|'heavy'

---@alias render.md.table.Style 'full'|'normal'|'none'

---@alias render.md.table.Cell 'trimmed'|'padded'|'raw'|'overlay'

---@class (exact) render.md.UserCustomCallout
---@field raw? string
---@field rendered? string
---@field highlight? string
---@field quote_icon? string
---@field category? string

---@class (exact) render.md.UserLink: render.md.UserBaseComponent
---@field footnote? render.md.UserFootnote
---@field image? string
---@field email? string
---@field hyperlink? string
---@field highlight? string
---@field wiki? render.md.UserWikiLink
---@field custom? table<string, render.md.UserLinkComponent>

---@class (exact) render.md.UserFootnote
---@field enabled? boolean
---@field superscript? boolean
---@field prefix? string
---@field suffix? string

---@class (exact) render.md.UserWikiLink
---@field icon? string
---@field body? fun(ctx: render.md.LinkContext): render.md.MarkText|string?
---@field highlight? string

---@class (exact) render.md.LinkContext
---@field buf integer
---@field row integer
---@field start_col integer
---@field end_col integer
---@field destination string
---@field alias? string

---@class (exact) render.md.UserLinkComponent
---@field pattern? string
---@field icon? string
---@field highlight? string

---@class (exact) render.md.UserSign
---@field enabled? boolean
---@field highlight? string

---@class (exact) render.md.UserInlineHighlight: render.md.UserBaseComponent
---@field highlight? string

---@class (exact) render.md.UserIndent: render.md.UserBaseComponent
---@field per_level? integer
---@field skip_level? integer
---@field skip_heading? boolean
---@field icon? string
---@field highlight? string

---@class (exact) render.md.UserLatex: render.md.UserBaseComponent
---@field converter? string
---@field highlight? string
---@field position? render.md.latex.Position
---@field top_pad? integer
---@field bottom_pad? integer

---@alias render.md.latex.Position 'above'|'below'

---@class (exact) render.md.UserHtml: render.md.UserBaseComponent
---@field comment? render.md.UserHtmlComment
---@field tag? table<string, render.md.HtmlTag>

---@class (exact) render.md.UserHtmlComment
---@field conceal? boolean
---@field text? string
---@field highlight? string

---@class (exact) render.md.HtmlTag
---@field icon string
---@field highlight string

---@class (exact) render.md.UserWindowOption
---@field default? render.md.option.Value
---@field rendered? render.md.option.Value

---@alias render.md.option.Value number|integer|string|boolean

---@class (exact) render.md.UserConfig: render.md.UserBufferConfig
---@field preset? render.md.config.Preset
---@field log_level? render.md.config.LogLevel
---@field log_runtime? boolean
---@field file_types? string[]
---@field change_events? string[]
---@field injections? table<string, render.md.UserInjection>
---@field patterns? table<string, render.md.UserPattern>
---@field on? render.md.UserCallback
---@field completions? render.md.UserCompletions
---@field overrides? render.md.UserConfigOverrides
---@field custom_handlers? table<string, render.md.Handler>

---@alias render.md.config.Preset 'none'|'lazy'|'obsidian'

---@alias render.md.config.LogLevel 'off'|'debug'|'info'|'error'

---@class (exact) render.md.UserInjection
---@field enabled? boolean
---@field query? string

---@class (exact) render.md.UserPattern
---@field disable? boolean
---@field directives? render.md.UserDirective[]

---@class (exact) render.md.UserDirective
---@field id? integer
---@field name? string

---@class (exact) render.md.UserCallback
---@field attach? fun(ctx: render.md.CallbackContext)
---@field render? fun(ctx: render.md.CallbackContext)
---@field clear? fun(ctx: render.md.CallbackContext)

---@class (exact) render.md.CallbackContext
---@field buf integer

---@class (exact) render.md.UserCompletions
---@field blink? render.md.UserCompletion
---@field coq? render.md.UserCompletion
---@field lsp? render.md.UserCompletion
---@field filter? render.md.UserCompletionFilter

---@class (exact) render.md.UserCompletion
---@field enabled? boolean

---@class (exact) render.md.UserCompletionFilter
---@field callout? fun(value: render.md.CustomCallout): boolean
---@field checkbox? fun(value: render.md.CustomCheckbox): boolean

---@class (exact) render.md.UserConfigOverrides
---@field buflisted? table<boolean, render.md.UserBufferConfig>
---@field buftype? table<string, render.md.UserBufferConfig>
---@field filetype? table<string, render.md.UserBufferConfig>

---@type render.md.Config
M.default_config = {
    -- Whether markdown should be rendered by default.
    enabled = true,
    -- Vim modes that will show a rendered view of the markdown file, :h mode(), for all enabled
    -- components. Individual components can be enabled for other modes. Remaining modes will be
    -- unaffected by this plugin.
    render_modes = { 'n', 'c', 't' },
    -- Maximum file size (in MB) that this plugin will attempt to render.
    -- Any file larger than this will effectively be ignored.
    max_file_size = 10.0,
    -- Milliseconds that must pass before updating marks, updates occur.
    -- within the context of the visible window, not the entire buffer.
    debounce = 100,
    -- Pre configured settings that will attempt to mimic various target user experiences.
    -- Any user provided settings will take precedence.
    -- | obsidian | mimic Obsidian UI                                          |
    -- | lazy     | will attempt to stay up to date with LazyVim configuration |
    -- | none     | does nothing                                               |
    preset = 'none',
    -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'.
    -- Only intended to be used for plugin development / debugging.
    log_level = 'error',
    -- Print runtime of main update method.
    -- Only intended to be used for plugin development / debugging.
    log_runtime = false,
    -- Filetypes this plugin will run on.
    file_types = { 'markdown' },
    -- Additional events that will trigger this plugin's render loop.
    change_events = {},
    -- Out of the box language injections for known filetypes that allow markdown to be interpreted
    -- in specified locations, see :h treesitter-language-injections.
    -- Set enabled to false in order to disable.
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
    -- Highlight patterns to disable for filetypes, i.e. lines concealed around code blocks
    patterns = {
        markdown = {
            disable = true,
            directives = {
                { id = 17, name = 'conceal_lines' },
                { id = 18, name = 'conceal_lines' },
            },
        },
    },
    anti_conceal = {
        -- This enables hiding any added text on the line the cursor is on.
        enabled = true,
        -- Which elements to always show, ignoring anti conceal behavior. Values can either be
        -- booleans to fix the behavior or string lists representing modes where anti conceal
        -- behavior will be ignored. Valid values are:
        --   head_icon, head_background, head_border, code_language, code_background, code_border,
        --   dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
        ignore = {
            code_background = true,
            sign = true,
        },
        -- Number of lines above cursor to show.
        above = 0,
        -- Number of lines below cursor to show.
        below = 0,
    },
    padding = {
        -- Highlight to use when adding whitespace, should match background.
        highlight = 'Normal',
    },
    latex = {
        -- Turn on / off latex rendering.
        enabled = true,
        -- Additional modes to render latex.
        render_modes = false,
        -- Executable used to convert latex formula to rendered unicode.
        converter = 'latex2text',
        -- Highlight for latex blocks.
        highlight = 'RenderMarkdownMath',
        -- Determines where latex formula is rendered relative to block.
        -- | above | above latex block |
        -- | below | below latex block |
        position = 'above',
        -- Number of empty lines above latex blocks.
        top_pad = 0,
        -- Number of empty lines below latex blocks.
        bottom_pad = 0,
    },
    on = {
        -- Called when plugin initially attaches to a buffer.
        attach = function() end,
        -- Called after plugin renders a buffer.
        render = function() end,
        -- Called after plugin clears a buffer.
        clear = function() end,
    },
    completions = {
        -- Settings for blink.cmp completions source
        blink = { enabled = false },
        -- Settings for coq_nvim completions source
        coq = { enabled = false },
        -- Settings for in-process language server completions
        lsp = { enabled = false },
        filter = {
            callout = function()
                -- example to exclude obsidian callouts
                -- return value.category ~= 'obsidian'
                return true
            end,
            checkbox = function()
                return true
            end,
        },
    },
    -- Useful context to have when evaluating values.
    -- | level    | the number of '#' in the heading marker         |
    -- | sections | for each level how deeply nested the heading is |
    heading = {
        -- Turn on / off heading icon & background rendering.
        enabled = true,
        -- Additional modes to render headings.
        render_modes = false,
        -- Turn on / off atx heading rendering.
        atx = true,
        -- Turn on / off setext heading rendering.
        setext = true,
        -- Turn on / off any sign column related rendering.
        sign = true,
        -- Replaces '#+' of 'atx_h._marker'.
        -- Output is evaluated depending on the type.
        -- | function | `value(context)`              |
        -- | string[] | `cycle(value, context.level)` |
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        -- Determines how icons fill the available space.
        -- | right   | '#'s are concealed and icon is appended to right side                          |
        -- | inline  | '#'s are concealed and icon is inlined on left side                            |
        -- | overlay | icon is left padded with spaces and inserted on left hiding any additional '#' |
        position = 'overlay',
        -- Added to the sign column if enabled.
        -- Output is evaluated by `cycle(value, context.level)`.
        signs = { '󰫎 ' },
        -- Width of the heading background.
        -- | block | width of the heading text |
        -- | full  | full width of the window  |
        -- Can also be a list of the above values evaluated by `clamp(value, context.level)`.
        width = 'full',
        -- Amount of margin to add to the left of headings.
        -- Margin available space is computed after accounting for padding.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        -- Can also be a list of numbers evaluated by `clamp(value, context.level)`.
        left_margin = 0,
        -- Amount of padding to add to the left of headings.
        -- Output is evaluated using the same logic as 'left_margin'.
        left_pad = 0,
        -- Amount of padding to add to the right of headings when width is 'block'.
        -- Output is evaluated using the same logic as 'left_margin'.
        right_pad = 0,
        -- Minimum width to use for headings when width is 'block'.
        -- Can also be a list of integers evaluated by `clamp(value, context.level)`.
        min_width = 0,
        -- Determines if a border is added above and below headings.
        -- Can also be a list of booleans evaluated by `clamp(value, context.level)`.
        border = false,
        -- Always use virtual lines for heading borders instead of attempting to use empty lines.
        border_virtual = false,
        -- Highlight the start of the border using the foreground highlight.
        border_prefix = false,
        -- Used above heading for border.
        above = '▄',
        -- Used below heading for border.
        below = '▀',
        -- Highlight for the heading icon and extends through the entire line.
        -- Output is evaluated by `clamp(value, context.level)`.
        backgrounds = {
            'RenderMarkdownH1Bg',
            'RenderMarkdownH2Bg',
            'RenderMarkdownH3Bg',
            'RenderMarkdownH4Bg',
            'RenderMarkdownH5Bg',
            'RenderMarkdownH6Bg',
        },
        -- Highlight for the heading and sign icons.
        -- Output is evaluated using the same logic as 'backgrounds'.
        foregrounds = {
            'RenderMarkdownH1',
            'RenderMarkdownH2',
            'RenderMarkdownH3',
            'RenderMarkdownH4',
            'RenderMarkdownH5',
            'RenderMarkdownH6',
        },
        -- Define custom heading patterns which allow you to override various properties based on
        -- the contents of a heading.
        -- The key is for healthcheck and to allow users to change its values, value type below.
        -- | pattern    | matched against the heading text @see :h lua-pattern |
        -- | icon       | optional override for the icon                       |
        -- | background | optional override for the background                 |
        -- | foreground | optional override for the foreground                 |
        custom = {},
    },
    paragraph = {
        -- Turn on / off paragraph rendering.
        enabled = true,
        -- Additional modes to render paragraphs.
        render_modes = false,
        -- Amount of margin to add to the left of paragraphs.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        left_margin = 0,
        -- Minimum width to use for paragraphs.
        min_width = 0,
    },
    code = {
        -- Turn on / off code block & inline code rendering.
        enabled = true,
        -- Additional modes to render code blocks.
        render_modes = false,
        -- Turn on / off any sign column related rendering.
        sign = true,
        -- Determines how code blocks & inline code are rendered.
        -- | none     | disables all rendering                                                    |
        -- | normal   | highlight group to code blocks & inline code, adds padding to code blocks |
        -- | language | language icon to sign column if enabled and icon + name above code blocks |
        -- | full     | normal + language                                                         |
        style = 'full',
        -- Determines where language icon is rendered.
        -- | right | right side of code block |
        -- | left  | left side of code block  |
        position = 'left',
        -- Amount of padding to add around the language.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        language_pad = 0,
        -- Whether to include the language icon above code blocks.
        language_icon = true,
        -- Whether to include the language name above code blocks.
        language_name = true,
        -- A list of language names for which background highlighting will be disabled.
        -- Likely because that language has background highlights itself.
        -- Use a boolean to make behavior apply to all languages.
        -- Borders above & below blocks will continue to be rendered.
        disable_background = { 'diff' },
        -- Width of the code block background.
        -- | block | width of the code block  |
        -- | full  | full width of the window |
        width = 'full',
        -- Amount of margin to add to the left of code blocks.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        -- Margin available space is computed after accounting for padding.
        left_margin = 0,
        -- Amount of padding to add to the left of code blocks.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        left_pad = 0,
        -- Amount of padding to add to the right of code blocks when width is 'block'.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        right_pad = 0,
        -- Minimum width to use for code blocks when width is 'block'.
        min_width = 0,
        -- Determines how the top / bottom of code block are rendered.
        -- | none  | do not render a border                               |
        -- | thick | use the same highlight as the code body              |
        -- | thin  | when lines are empty overlay the above & below icons |
        -- | hide  | conceal lines unless language name or icon is added  |
        border = 'hide',
        -- Used above code blocks for thin border.
        above = '▄',
        -- Used below code blocks for thin border.
        below = '▀',
        -- Icon to add to the left of inline code.
        inline_left = '',
        -- Icon to add to the right of inline code.
        inline_right = '',
        -- Padding to add to the left & right of inline code.
        inline_pad = 0,
        -- Highlight for code blocks.
        highlight = 'RenderMarkdownCode',
        -- Highlight for language, overrides icon provider value.
        highlight_language = nil,
        -- Highlight for border, use false to add no highlight.
        highlight_border = 'RenderMarkdownCodeBorder',
        -- Highlight for language, used if icon provider does not have a value.
        highlight_fallback = 'RenderMarkdownCodeFallback',
        -- Highlight for inline code.
        highlight_inline = 'RenderMarkdownCodeInline',
    },
    dash = {
        -- Turn on / off thematic break rendering.
        enabled = true,
        -- Additional modes to render dash.
        render_modes = false,
        -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'.
        -- The icon gets repeated across the window's width.
        icon = '─',
        -- Width of the generated line.
        -- | <number> | a hard coded width value |
        -- | full     | full width of the window |
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        width = 'full',
        -- Amount of margin to add to the left of dash.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        left_margin = 0,
        -- Highlight for the whole line generated from the icon.
        highlight = 'RenderMarkdownDash',
    },
    -- Useful context to have when evaluating values.
    -- | level | how deeply nested the list is, 1-indexed          |
    -- | index | how far down the item is at that level, 1-indexed |
    -- | value | text value of the marker node                     |
    bullet = {
        -- Turn on / off list bullet rendering
        enabled = true,
        -- Additional modes to render list bullets
        render_modes = false,
        -- Replaces '-'|'+'|'*' of 'list_item'.
        -- If the item is a 'checkbox' a conceal is used to hide the bullet instead.
        -- Output is evaluated depending on the type.
        -- | function   | `value(context)`                                    |
        -- | string     | `value`                                             |
        -- | string[]   | `cycle(value, context.level)`                       |
        -- | string[][] | `clamp(cycle(value, context.level), context.index)` |
        icons = { '●', '○', '◆', '◇' },
        -- Replaces 'n.'|'n)' of 'list_item'.
        -- Output is evaluated using the same logic as 'icons'.
        ordered_icons = function(ctx)
            local value = vim.trim(ctx.value)
            local index = tonumber(value:sub(1, #value - 1))
            return string.format('%d.', index > 1 and index or ctx.index)
        end,
        -- Padding to add to the left of bullet point.
        -- Output is evaluated depending on the type.
        -- | function | `value(context)` |
        -- | integer  | `value`          |
        left_pad = 0,
        -- Padding to add to the right of bullet point.
        -- Output is evaluated using the same logic as 'left_pad'.
        right_pad = 0,
        -- Highlight for the bullet icon.
        -- Output is evaluated using the same logic as 'icons'.
        highlight = 'RenderMarkdownBullet',
        -- Highlight for item associated with the bullet point.
        -- Output is evaluated using the same logic as 'icons'.
        scope_highlight = {},
    },
    -- Checkboxes are a special instance of a 'list_item' that start with a 'shortcut_link'.
    -- There are two special states for unchecked & checked defined in the markdown grammar.
    checkbox = {
        -- Turn on / off checkbox state rendering.
        enabled = true,
        -- Additional modes to render checkboxes.
        render_modes = false,
        -- Padding to add to the right of checkboxes.
        right_pad = 1,
        unchecked = {
            -- Replaces '[ ]' of 'task_list_marker_unchecked'.
            icon = '󰄱 ',
            -- Highlight for the unchecked icon.
            highlight = 'RenderMarkdownUnchecked',
            -- Highlight for item associated with unchecked checkbox.
            scope_highlight = nil,
        },
        checked = {
            -- Replaces '[x]' of 'task_list_marker_checked'.
            icon = '󰱒 ',
            -- Highlight for the checked icon.
            highlight = 'RenderMarkdownChecked',
            -- Highlight for item associated with checked checkbox.
            scope_highlight = nil,
        },
        -- Define custom checkbox states, more involved, not part of the markdown grammar.
        -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks.
        -- The key is for healthcheck and to allow users to change its values, value type below.
        -- | raw             | matched against the raw text of a 'shortcut_link'           |
        -- | rendered        | replaces the 'raw' value when rendering                     |
        -- | highlight       | highlight for the 'rendered' icon                           |
        -- | scope_highlight | optional highlight for item associated with custom checkbox |
        custom = {
            todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
        },
    },
    quote = {
        -- Turn on / off block quote & callout rendering.
        enabled = true,
        -- Additional modes to render quotes.
        render_modes = false,
        -- Replaces '>' of 'block_quote'.
        icon = '▋',
        -- Whether to repeat icon on wrapped lines. Requires neovim >= 0.10. This will obscure text
        -- if incorrectly configured with :h 'showbreak', :h 'breakindent' and :h 'breakindentopt'.
        -- A combination of these that is likely to work follows.
        -- | showbreak      | '  ' (2 spaces)   |
        -- | breakindent    | true              |
        -- | breakindentopt | '' (empty string) |
        -- These are not validated by this plugin. If you want to avoid adding these to your main
        -- configuration then set them in win_options for this plugin.
        repeat_linebreak = false,
        -- Highlight for the quote icon.
        highlight = 'RenderMarkdownQuote',
    },
    pipe_table = {
        -- Turn on / off pipe table rendering.
        enabled = true,
        -- Additional modes to render pipe tables.
        render_modes = false,
        -- Pre configured settings largely for setting table border easier.
        -- | heavy  | use thicker border characters     |
        -- | double | use double line border characters |
        -- | round  | use round border corners          |
        -- | none   | does nothing                      |
        preset = 'none',
        -- Determines how the table as a whole is rendered.
        -- | none   | disables all rendering                                                  |
        -- | normal | applies the 'cell' style rendering to each row of the table             |
        -- | full   | normal + a top & bottom line that fill out the table when lengths match |
        style = 'full',
        -- Determines how individual cells of a table are rendered.
        -- | overlay | writes completely over the table, removing conceal behavior and highlights |
        -- | raw     | replaces only the '|' characters in each row, leaving the cells unmodified |
        -- | padded  | raw + cells are padded to maximum visual width for each column             |
        -- | trimmed | padded except empty space is subtracted from visual width calculation      |
        cell = 'padded',
        -- Amount of space to put between cell contents and border.
        padding = 1,
        -- Minimum column width to use for padded or trimmed cell.
        min_width = 0,
        -- Characters used to replace table border.
        -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal.
        -- stylua: ignore
        border = {
            '┌', '┬', '┐',
            '├', '┼', '┤',
            '└', '┴', '┘',
            '│', '─',
        },
        -- Gets placed in delimiter row for each column, position is based on alignment.
        alignment_indicator = '━',
        -- Highlight for table heading, delimiter, and the line above.
        head = 'RenderMarkdownTableHead',
        -- Highlight for everything else, main table rows and the line below.
        row = 'RenderMarkdownTableRow',
        -- Highlight for inline padding used to add back concealed space.
        filler = 'RenderMarkdownTableFill',
    },
    -- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'.
    -- The key is for healthcheck and to allow users to change its values, value type below.
    -- | raw        | matched against the raw text of a 'shortcut_link', case insensitive |
    -- | rendered   | replaces the 'raw' value when rendering                             |
    -- | highlight  | highlight for the 'rendered' text and quote markers                 |
    -- | quote_icon | optional override for quote.icon value for individual callout       |
    -- | category   | optional metadata useful for filtering                              |
    -- stylua: ignore
    callout = {
        note      = { raw = '[!NOTE]',      rendered = '󰋽 Note',      highlight = 'RenderMarkdownInfo',    category = 'github'   },
        tip       = { raw = '[!TIP]',       rendered = '󰌶 Tip',       highlight = 'RenderMarkdownSuccess', category = 'github'   },
        important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint',    category = 'github'   },
        warning   = { raw = '[!WARNING]',   rendered = '󰀪 Warning',   highlight = 'RenderMarkdownWarn',    category = 'github'   },
        caution   = { raw = '[!CAUTION]',   rendered = '󰳦 Caution',   highlight = 'RenderMarkdownError',   category = 'github'   },
        -- Obsidian: https://help.obsidian.md/Editing+and+formatting/Callouts
        abstract  = { raw = '[!ABSTRACT]',  rendered = '󰨸 Abstract',  highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        summary   = { raw = '[!SUMMARY]',   rendered = '󰨸 Summary',   highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        tldr      = { raw = '[!TLDR]',      rendered = '󰨸 Tldr',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        info      = { raw = '[!INFO]',      rendered = '󰋽 Info',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        todo      = { raw = '[!TODO]',      rendered = '󰗡 Todo',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
        hint      = { raw = '[!HINT]',      rendered = '󰌶 Hint',      highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
        success   = { raw = '[!SUCCESS]',   rendered = '󰄬 Success',   highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
        check     = { raw = '[!CHECK]',     rendered = '󰄬 Check',     highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
        done      = { raw = '[!DONE]',      rendered = '󰄬 Done',      highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
        question  = { raw = '[!QUESTION]',  rendered = '󰘥 Question',  highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
        help      = { raw = '[!HELP]',      rendered = '󰘥 Help',      highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
        faq       = { raw = '[!FAQ]',       rendered = '󰘥 Faq',       highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
        attention = { raw = '[!ATTENTION]', rendered = '󰀪 Attention', highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
        failure   = { raw = '[!FAILURE]',   rendered = '󰅖 Failure',   highlight = 'RenderMarkdownError',   category = 'obsidian' },
        fail      = { raw = '[!FAIL]',      rendered = '󰅖 Fail',      highlight = 'RenderMarkdownError',   category = 'obsidian' },
        missing   = { raw = '[!MISSING]',   rendered = '󰅖 Missing',   highlight = 'RenderMarkdownError',   category = 'obsidian' },
        danger    = { raw = '[!DANGER]',    rendered = '󱐌 Danger',    highlight = 'RenderMarkdownError',   category = 'obsidian' },
        error     = { raw = '[!ERROR]',     rendered = '󱐌 Error',     highlight = 'RenderMarkdownError',   category = 'obsidian' },
        bug       = { raw = '[!BUG]',       rendered = '󰨰 Bug',       highlight = 'RenderMarkdownError',   category = 'obsidian' },
        example   = { raw = '[!EXAMPLE]',   rendered = '󰉹 Example',   highlight = 'RenderMarkdownHint' ,   category = 'obsidian' },
        quote     = { raw = '[!QUOTE]',     rendered = '󱆨 Quote',     highlight = 'RenderMarkdownQuote',   category = 'obsidian' },
        cite      = { raw = '[!CITE]',      rendered = '󱆨 Cite',      highlight = 'RenderMarkdownQuote',   category = 'obsidian' },
    },
    link = {
        -- Turn on / off inline link icon rendering.
        enabled = true,
        -- Additional modes to render links.
        render_modes = false,
        -- How to handle footnote links, start with a '^'.
        footnote = {
            -- Turn on / off footnote rendering.
            enabled = true,
            -- Replace value with superscript equivalent.
            superscript = true,
            -- Added before link content.
            prefix = '',
            -- Added after link content.
            suffix = '',
        },
        -- Inlined with 'image' elements.
        image = '󰥶 ',
        -- Inlined with 'email_autolink' elements.
        email = '󰀓 ',
        -- Fallback icon for 'inline_link' and 'uri_autolink' elements.
        hyperlink = '󰌹 ',
        -- Applies to the inlined icon as a fallback.
        highlight = 'RenderMarkdownLink',
        -- Applies to WikiLink elements.
        wiki = {
            icon = '󱗖 ',
            body = function()
                return nil
            end,
            highlight = 'RenderMarkdownWikiLink',
        },
        -- Define custom destination patterns so icons can quickly inform you of what a link
        -- contains. Applies to 'inline_link', 'uri_autolink', and wikilink nodes. When multiple
        -- patterns match a link the one with the longer pattern is used.
        -- The key is for healthcheck and to allow users to change its values, value type below.
        -- | pattern   | matched against the destination text, @see :h lua-pattern       |
        -- | icon      | gets inlined before the link text                               |
        -- | highlight | optional highlight for 'icon', uses fallback highlight if empty |
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
        -- Turn on / off sign rendering.
        enabled = true,
        -- Applies to background of sign text.
        highlight = 'RenderMarkdownSign',
    },
    -- Mimics Obsidian inline highlights when content is surrounded by double equals.
    -- The equals on both ends are concealed and the inner content is highlighted.
    inline_highlight = {
        -- Turn on / off inline highlight rendering.
        enabled = true,
        -- Additional modes to render inline highlights.
        render_modes = false,
        -- Applies to background of surrounded text.
        highlight = 'RenderMarkdownInlineHighlight',
    },
    -- Mimic org-indent-mode behavior by indenting everything under a heading based on the level of
    -- the heading. Indenting starts from level 2 headings onward by default.
    indent = {
        -- Turn on / off org-indent-mode.
        enabled = false,
        -- Additional modes to render indents.
        render_modes = false,
        -- Amount of additional padding added for each heading level.
        per_level = 2,
        -- Heading levels <= this value will not be indented.
        -- Use 0 to begin indenting from the very first level.
        skip_level = 1,
        -- Do not indent heading titles, only the body.
        skip_heading = false,
        -- Prefix added when indenting, one per level.
        icon = '▎',
        -- Applied to icon.
        highlight = 'RenderMarkdownIndent',
    },
    html = {
        -- Turn on / off all HTML rendering.
        enabled = true,
        -- Additional modes to render HTML.
        render_modes = false,
        comment = {
            -- Turn on / off HTML comment concealing.
            conceal = true,
            -- Optional text to inline before the concealed comment.
            text = nil,
            -- Highlight for the inlined text.
            highlight = 'RenderMarkdownHtmlComment',
        },
        -- HTML tags whose start and end will be hidden and icon shown.
        -- The key is matched against the tag name, value type below.
        -- | icon      | gets inlined at the start |
        -- | highlight | highlight for the icon    |
        tag = {},
    },
    -- Window options to use that change between rendered and raw view.
    win_options = {
        -- @see :h 'conceallevel'
        conceallevel = {
            -- Used when not being rendered, get user setting.
            default = vim.o.conceallevel,
            -- Used when being rendered, concealed text is completely hidden.
            rendered = 3,
        },
        -- @see :h 'concealcursor'
        concealcursor = {
            -- Used when not being rendered, get user setting.
            default = vim.o.concealcursor,
            -- Used when being rendered, show concealed text in all modes.
            rendered = '',
        },
    },
    -- More granular configuration mechanism, allows different aspects of buffers to have their own
    -- behavior. Values default to the top level configuration if no override is provided. Supports
    -- the following fields:
    --   enabled, max_file_size, debounce, render_modes, anti_conceal, padding, heading, paragraph,
    --   code, dash, bullet, checkbox, quote, pipe_table, callout, link, sign, indent, latex, html,
    --   win_options
    overrides = {
        -- Override for different buflisted values, @see :h 'buflisted'.
        buflisted = {},
        -- Override for different buftype values, @see :h 'buftype'.
        buftype = {
            nofile = {
                render_modes = true,
                padding = { highlight = 'NormalFloat' },
                sign = { enabled = false },
            },
        },
        -- Override for different filetype values, @see :h 'filetype'.
        filetype = {},
    },
    -- Mapping from treesitter language to user defined handlers.
    -- @see [Custom Handlers](doc/custom-handlers.md)
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
