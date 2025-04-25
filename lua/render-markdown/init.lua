---@class render.md.Init: render.md.Api
local M = {}

---@class (exact) render.md.Config: render.md.buffer.Config
---@field preset render.md.config.Preset
---@field log_level render.md.log.Level
---@field log_runtime boolean
---@field file_types string[]
---@field ignore fun(buf: integer): boolean
---@field change_events string[]
---@field injections table<string, render.md.injection.Config>
---@field patterns table<string, render.md.pattern.Config>
---@field on render.md.callback.Config
---@field completions render.md.completions.Config
---@field overrides render.md.overrides.Config
---@field custom_handlers table<string, render.md.Handler>

---@class (exact) render.md.buffer.Config: render.md.base.Config
---@field max_file_size number
---@field debounce integer
---@field anti_conceal render.md.anti.conceal.Config
---@field bullet render.md.bullet.Config
---@field callout table<string, render.md.callout.Config>
---@field checkbox render.md.checkbox.Config
---@field code render.md.code.Config
---@field dash render.md.dash.Config
---@field document render.md.document.Config
---@field heading render.md.heading.Config
---@field html render.md.html.Config
---@field indent render.md.indent.Config
---@field inline_highlight render.md.inline.highlight.Config
---@field latex render.md.latex.Config
---@field link render.md.link.Config
---@field padding render.md.padding.Config
---@field paragraph render.md.paragraph.Config
---@field pipe_table render.md.table.Config
---@field quote render.md.quote.Config
---@field sign render.md.sign.Config
---@field win_options table<string, render.md.window.Config>

---@private
---@type boolean
M.initialized = false

---@type render.md.Config
M.default = {
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
    -- Takes buffer as input, if it returns true this plugin will not attach to the buffer
    ignore = function()
        return false
    end,
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
        -- Called before adding marks to the buffer for the first time.
        initial = function() end,
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
        -- | pattern    | matched against the heading text @see :h lua-patterns |
        -- | icon       | optional override for the icon                        |
        -- | background | optional override for the background                  |
        -- | foreground | optional override for the foreground                  |
        custom = {},
    },
    -- Useful context to have when evaluating values.
    -- | text | text value of the node |
    paragraph = {
        -- Turn on / off paragraph rendering.
        enabled = true,
        -- Additional modes to render paragraphs.
        render_modes = false,
        -- Amount of margin to add to the left of paragraphs.
        -- If a float < 1 is provided it is treated as a percentage of available window space.
        -- Output is evaluated depending on the type.
        -- | function | `value(context)` |
        -- | number   | `value`          |
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
    document = {
        -- Turn on / off document rendering.
        enabled = true,
        -- Additional modes to render document.
        render_modes = false,
        -- Ability to conceal arbitrary ranges of text based on lua patterns, @see :h lua-patterns.
        -- Relies entirely on user to set patterns that handle their edge cases.
        conceal = {
            -- Matched ranges will be concealed using character level conceal.
            char_patterns = {},
            -- Matched ranges will be concealed using line level conceal.
            line_patterns = {},
        },
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
        -- stylua: ignore
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
        -- If a list is provided output is evaluated by `cycle(value, level)`.
        highlight = {
            'RenderMarkdownQuote1',
            'RenderMarkdownQuote2',
            'RenderMarkdownQuote3',
            'RenderMarkdownQuote4',
            'RenderMarkdownQuote5',
            'RenderMarkdownQuote6',
        },
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
        -- | pattern   | matched against the destination text                            |
        -- | icon      | gets inlined before the link text                               |
        -- | kind      | optional determines how pattern is checked                      |
        -- |           | pattern | @see :h lua-patterns, is the default if not set       |
        -- |           | suffix  | @see :h vim.endswith()                                |
        -- | priority  | optional used when multiple match, uses pattern length if empty |
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
    if M.initialized and vim.tbl_count(opts or {}) == 0 then
        return
    end
    M.initialized = true
    local config = M.resolve_config(opts or {})
    require('render-markdown.state').setup(config)
end

---@private
---@param user render.md.UserConfig
---@return render.md.Config
function M.resolve_config(user)
    local preset = require('render-markdown.presets').get(user)
    local config = vim.tbl_deep_extend('force', M.default, preset, user)
    -- override settings that require neovim >= 0.10.0 and have compatible alternatives
    local has_10 = require('render-markdown.lib.compat').has_10
    if not has_10 then
        config.code.position = 'right'
    end
    -- use lazy.nvim file type configuration if available and no user value is specified
    if user.file_types == nil then
        local lazy_file_types = require('render-markdown.lib.env').lazy('ft')
        if #lazy_file_types > 0 then
            config.file_types = lazy_file_types
        end
    end
    return config
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('render-markdown.api')[key]
    end,
})
