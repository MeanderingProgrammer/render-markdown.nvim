# render-markdown.nvim

Plugin to improve viewing Markdown files in Neovim

<!-- panvimdoc-ignore-start -->

| Screenshot | Video     |
| ---------- | --------- |
| ![Heading](https://github.com/user-attachments/assets/36f0fbb6-99bc-4cb2-8f69-fbea3d10abf1) | ![Heading](https://github.com/user-attachments/assets/e57a53ea-f0bf-48db-90c1-0c2365ab3c54) |
| ![Table](https://github.com/user-attachments/assets/cbb81758-820d-467c-bc44-07003cb532bb)   | ![Table](https://github.com/user-attachments/assets/5cd2b69d-ef17-4c6e-9510-59ed10e385d5)   |
| ![Quote](https://github.com/user-attachments/assets/822ae62c-bc0f-40a7-b8bb-fb3a885a95f9)   | ![Quote](https://github.com/user-attachments/assets/aa002ac7-b30f-4079-bba9-505160a4ad78)   |
| ![Callout](https://github.com/user-attachments/assets/397ddd7b-bb82-47d0-ad9d-bdbe2f9858d7) | ![Callout](https://github.com/user-attachments/assets/250aaeda-6141-4f4c-b72c-103875ca6eb8) |
| ![LaTeX](https://github.com/user-attachments/assets/7b859c0a-1bf6-4398-88b5-7bcde12f2390)   | ![LaTeX](https://github.com/user-attachments/assets/9ef14030-f688-47fd-95ff-befab1253322)   |

<!-- panvimdoc-ignore-end -->

# Features

- Contained: runs entirely inside Neovim with no external windows
- Configurable: all components, padding, icons, and colors can be modified
- File type agnostic: can render `markdown` injected into any file
  - Automatically runs on lazy load file types defined in `lazy.nvim` `ft`
- Injections: can directly manipulate treesitter to add logical `markdown` sections
- Modal rendering: changes between `rendered` and `raw` view based on mode
- Anti-conceal: hides virtual text added by this plugin on cursor line
- Window options: changes option values between `rendered` and `raw` view
- Large files: only renders visible range, can be entirely disabled based on size
- Custom rendering: provides extension point where user can add anything
- Renders the following `markdown` components out of the box:
  - Headings: icon, color, border, padding [^1], width
  - Code blocks: background, language icon [^1] [^2], border, padding [^1], width
  - Code inline: background
  - Horizontal breaks: icon, color, width
  - List bullets: icon, color, padding [^1]
  - Checkboxes: icon, color, user defined states [^1]
  - Block quotes: icon, color, line breaks [^1]
  - Callouts: icon, color, user defined values, Github & Obsidian defaults
  - Tables: border, color, alignment indicator, auto align cells [^1]
  - Links [^1]: icon, color, user defined destinations
  - `LaTeX` blocks [^3]: renders formulas
  - Org indent mode [^1]: per level padding

[^1]: Requires neovim >= `0.10.0`
[^2]: Requires icon provider, `mini.icons` or `nvim-web-devicons`
[^3]: Requires `latex` parser and `pylatexenc`

# Requirements

- Neovim `>= 0.9.0` (minimum) `>= 0.10.0` (recommended)
- Nerd font symbols: [more details](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Fonts)
- [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) parsers:
  - [markdown & markdown_inline](https://github.com/tree-sitter-grammars/tree-sitter-markdown):
    Used to parse `markdown` files
  - [latex](https://github.com/latex-lsp/tree-sitter-latex) (Optional):
    Used to get `LaTeX` blocks from `markdown` files
  - [html](https://github.com/tree-sitter/tree-sitter-html) (Optional):
    Used to conceal `HTML` comments
- Icon provider plugin (Optional): Used for icon above code blocks
  - [mini.icons](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-icons.md)
  - [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- System dependencies:
  - [pylatexenc](https://pypi.org/project/pylatexenc/) (Optional):
    Used to transform `LaTeX` strings to appropriate unicode using `latex2text`

# Install

## lazy.nvim

```lua
{
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
}
```

## rocks.nvim

This plugin is available on [LuaRocks](https://luarocks.org/modules/MeanderingProgrammer/render-markdown.nvim)

```vim
:Rocks install render-markdown.nvim
```

## packer.nvim

```lua
use({
    'MeanderingProgrammer/render-markdown.nvim',
    after = { 'nvim-treesitter' },
    requires = { 'echasnovski/mini.nvim', opt = true }, -- if you use the mini.nvim suite
    -- requires = { 'echasnovski/mini.icons', opt = true }, -- if you use standalone mini plugins
    -- requires = { 'nvim-tree/nvim-web-devicons', opt = true }, -- if you prefer nvim-web-devicons
    config = function()
        require('render-markdown').setup({})
    end,
})
```

# Commands

| Command                    | Lua Function                            | Description                                       |
| -------------------------- | --------------------------------------- | ------------------------------------------------- |
| `:RenderMarkdown`          | `require('render-markdown').enable()`   | Enable this plugin                                |
| `:RenderMarkdown enable`   | `require('render-markdown').enable()`   | Enable this plugin                                |
| `:RenderMarkdown disable`  | `require('render-markdown').disable()`  | Disable this plugin                               |
| `:RenderMarkdown toggle`   | `require('render-markdown').toggle()`   | Switch between enabling & disabling this plugin   |
| `:RenderMarkdown log`      | `require('render-markdown').log()`      | Opens the log file for this plugin                |
| `:RenderMarkdown expand`   | `require('render-markdown').expand()`   | Increase anti-conceal margin above and below by 1 |
| `:RenderMarkdown contract` | `require('render-markdown').contract()` | Decrease anti-conceal margin above and below by 1 |
| `:RenderMarkdown debug`    | `require('render-markdown').debug()`    | Prints information about marks on current line    |
| `:RenderMarkdown config`   | `require('render-markdown').config()`   | Prints difference between config and default      |

# Completions

This plugin provides completions for both checkboxes and callouts provided you follow
the relevant setup.

## nvim-cmp

```lua
local cmp = require('cmp')
cmp.setup({
    sources = cmp.config.sources({
        { name = 'render-markdown' },
    }),
})
```

## blink.cmp

```lua
require('blink.cmp').setup({
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'markdown' },
        providers = {
            markdown = {
                name = 'RenderMarkdown',
                module = 'render-markdown.integ.blink',
                fallbacks = { 'lsp' },
            },
        },
    },
})
```

## coq_nvim

```lua
require('render-markdown.integ.coq').setup()
```

# Setup

Checkout the [Wiki](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki)
for examples and images associated with different configuration options.

The full default configuration is provided below for reference.

Any part of it can be modified however for many fields this does not make much sense.

Some of the more useful fields are discussed further down.

<details>

<summary>Default Configuration</summary>

```lua
require('render-markdown').setup({
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
            youtube = { pattern = 'youtube%.com', icon = '󰗃 ' },
            github = { pattern = 'github%.com', icon = '󰊤 ' },
            neovim = { pattern = 'neovim%.io', icon = ' ' },
            stackoverflow = { pattern = 'stackoverflow%.com', icon = '󰓌 ' },
            discord = { pattern = 'discord%.com', icon = '󰙯 ' },
            reddit = { pattern = 'reddit%.com', icon = '󰑍 ' },
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
})
```

</details>

We use the following definitions when discussing indexing into lists:

1. Cycle: Indexed `mod` the length.
   Example: `{ 1, 2, 3 }` @ 4 = 1.
2. Clamp: Indexed normally but larger values use the last value in the list.
   Example: `{ 1, 2, 3 }` @ 4 = 3.

## Headings

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Headings)

<details>

<summary>Heading Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

## Paragraphs

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Paragraphs)

<details>

<summary>Paragraph Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

## Code Blocks

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/CodeBlocks)

<details>

<summary>Code Block Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

## Dashed Line

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/DashedLine)

<details>

<summary>Dashed Line Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

## List Bullets

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/ListBullets)

<details>

<summary>Bullet Point Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

## Checkboxes

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Checkboxes)

<details>

<summary>Checkbox Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

## Block Quotes

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/BlockQuotes)

<details>

<summary>Block Quote Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

## Tables

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Tables)

<details>

<summary>Table Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

## Callouts

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Callouts)

<details>

<summary>Callout Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

## Links

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Links)

<details>

<summary>Link Configuration</summary>

```lua
require('render-markdown').setup({
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
            youtube = { pattern = 'youtube%.com', icon = '󰗃 ' },
            github = { pattern = 'github%.com', icon = '󰊤 ' },
            neovim = { pattern = 'neovim%.io', icon = ' ' },
            stackoverflow = { pattern = 'stackoverflow%.com', icon = '󰓌 ' },
            discord = { pattern = 'discord%.com', icon = '󰙯 ' },
            reddit = { pattern = 'reddit%.com', icon = '󰑍 ' },
        },
    },
})
```

</details>

## Signs

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Signs)

<details>

<summary>Sign Configuration</summary>

```lua
require('render-markdown').setup({
    sign = {
        -- Turn on / off sign rendering
        enabled = true,
        -- Applies to background of sign text
        highlight = 'RenderMarkdownSign',
    },
})
```

</details>

## Indent

[Wiki Page](https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Indent)

<details>

<summary>Indent Configuration</summary>

```lua
require('render-markdown').setup({
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
})
```

</details>

# Colors

The table below shows all the highlight groups with their default link

| Highlight Group               | Default Group                      | Description                |
| ----------------------------- | ---------------------------------- | -------------------------- |
| RenderMarkdownH1              | @markup.heading.1.markdown         | H1 icons                   |
| RenderMarkdownH2              | @markup.heading.2.markdown         | H2 icons                   |
| RenderMarkdownH3              | @markup.heading.3.markdown         | H3 icons                   |
| RenderMarkdownH4              | @markup.heading.4.markdown         | H4 icons                   |
| RenderMarkdownH5              | @markup.heading.5.markdown         | H5 icons                   |
| RenderMarkdownH6              | @markup.heading.6.markdown         | H6 icons                   |
| RenderMarkdownH1Bg            | DiffAdd                            | H1 background line         |
| RenderMarkdownH2Bg            | DiffChange                         | H2 background line         |
| RenderMarkdownH3Bg            | DiffDelete                         | H3 background line         |
| RenderMarkdownH4Bg            | DiffDelete                         | H4 background line         |
| RenderMarkdownH5Bg            | DiffDelete                         | H5 background line         |
| RenderMarkdownH6Bg            | DiffDelete                         | H6 background line         |
| RenderMarkdownCode            | ColorColumn                        | Code block background      |
| RenderMarkdownCodeInline      | RenderMarkdownCode                 | Inline code background     |
| RenderMarkdownInlineHighlight | RenderMarkdownCodeInline           | Inline highlights contents |
| RenderMarkdownBullet          | Normal                             | List item bullet points    |
| RenderMarkdownQuote           | @markup.quote                      | Block quote marker         |
| RenderMarkdownDash            | LineNr                             | Thematic break line        |
| RenderMarkdownSign            | SignColumn                         | Sign column background     |
| RenderMarkdownMath            | @markup.math                       | LaTeX lines                |
| RenderMarkdownHtmlComment     | @comment                           | HTML comment inline text   |
| RenderMarkdownLink            | @markup.link.label.markdown_inline | Image & hyperlink icons    |
| RenderMarkdownWikiLink        | RenderMarkdownLink                 | WikiLink icon & text       |
| RenderMarkdownUnchecked       | @markup.list.unchecked             | Unchecked checkbox         |
| RenderMarkdownChecked         | @markup.list.checked               | Checked checkbox           |
| RenderMarkdownTodo            | @markup.raw                        | Todo custom checkbox       |
| RenderMarkdownTableHead       | @markup.heading                    | Pipe table heading rows    |
| RenderMarkdownTableRow        | Normal                             | Pipe table body rows       |
| RenderMarkdownTableFill       | Conceal                            | Pipe table inline padding  |
| RenderMarkdownSuccess         | DiagnosticOk                       | Success related callouts   |
| RenderMarkdownInfo            | DiagnosticInfo                     | Info related callouts      |
| RenderMarkdownHint            | DiagnosticHint                     | Hint related callouts      |
| RenderMarkdownWarn            | DiagnosticWarn                     | Warning related callouts   |
| RenderMarkdownError           | DiagnosticError                    | Error related callouts     |

# Info

## vimwiki

> [!NOTE]
>
> [vimwiki](https://github.com/vimwiki/vimwiki) overrides the `filetype` of
> `markdown` files, as such there are additional setup steps.
>
> - Add `vimwiki` to the `file_types` configuration of this plugin
>
> ```lua
> require('render-markdown').setup({
>     file_types = { 'markdown', 'vimwiki' },
> })
> ```
>
> - Register `markdown` as the parser for `vimwiki` files
>
> ```lua
> vim.treesitter.language.register('markdown', 'vimwiki')
> ```

## obsidian.nvim

> [!NOTE]
>
> [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) provides UI functionality
> that is enabled by default. While there may be a way to have the 2 work together,
> for the foreseeable future only one of these plugins should be used for the UI.
> If you choose this plugin disable the `obsidian.nvim` UI with:
>
> ```lua
> require('obsidian').setup({
>     ui = { enable = false },
> })
> ```
>
> You can also do something more custom like lazy loading this plugin via a command
> and adding logic to the config method to disable `obsidian.nvim` as suggested in
> [#116](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/116),
> though things like this can break at any time given the reliance on internal logic:
>
> ```lua
> return {
>     'MeanderingProgrammer/render-markdown.nvim',
>     cmd = { 'RenderMarkdown' },
>     dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
>     config = function()
>         require('obsidian').get_client().opts.ui.enable = false
>         vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_get_namespaces()['ObsidianUI'], 0, -1)
>         require('render-markdown').setup({})
>     end,
> }
> ```

## Images

> [!NOTE]
>
> Images are only supported so far as this plugin will not interfere with others
> like [image.nvim](https://github.com/3rd/image.nvim), however nothing is done
> natively by this plugin.
> It is recommended to enable the `only_render_image_at_cursor` option.

## Additional

- [Limitations](doc/limitations.md): Known limitations of this plugin
- [Custom Handlers](doc/custom-handlers.md): Allow users to integrate custom rendering
  for either unsupported languages or to override / extend builtin implementations
- [Troubleshooting Guide](doc/troubleshooting.md)
- [Purpose](doc/purpose.md): Why this plugin exists
- [Markdown Ecosystem](doc/markdown-ecosystem.md): Information about other `markdown`
  related plugins and how they co-exist

<!-- panvimdoc-ignore-start -->

# Donate

I enjoy working on these projects and will continue to do so with the time I can
find. Any support is appreciated including starring the repo and reporting issues.
Money is also nice: [Donate via Stripe](https://donate.stripe.com/4gw2bSbwA5gw5s48ww).

<!-- panvimdoc-ignore-end -->
