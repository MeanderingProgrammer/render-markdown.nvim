# markdown.nvim

Plugin to improve viewing Markdown files in Neovim

|                                            |                                    |
| ------------------------------------------ | ---------------------------------- |
| ![Heading Code](demo/heading_code.gif)     | ![List Table](demo/list_table.gif) |
| ![Box Dash Quote](demo/box_dash_quote.gif) | ![LaTeX](demo/latex.gif)           |
| ![Callout](demo/callout.gif)               |                                    |

# Features

- Functions entirely inside of Neovim with no external windows
- Changes between `rendered` view in normal mode and `raw` view in all other modes
- Changes window options between `rendered` and `raw` view based on configuration
  - Effects `conceallevel` & `concealcursor` by default
- Supports rendering `markdown` injected into other file types
- Renders the following `markdown` components:
  - Headings: highlight depending on level and replaces `#` with icon
  - Horizontal breaks: replace with full-width lines
  - Code blocks: highlight to better stand out
    - Adds language icon, requires icon provider (`mini.icons` or `nvim-web-devicons`)
      and neovim >= `0.10.0`
  - Inline code: highlight to better stand out
  - List bullet points: replace with provided icon based on level
  - Checkboxes: replace with provided icon based on whether they are checked
  - Block quotes: replace leading `>` with provided icon
  - Tables: replace border characters, does NOT automatically align
  - [Callouts](https://github.com/orgs/community/discussions/16925)
    - Base set as well as custom ones
  - Custom checkbox states, function similar to `callouts`
  - `LaTeX` blocks: renders formulas if `latex` parser and `pylatexenc` are installed
- Disable rendering when file is larger than provided value
- Support custom handlers which are ran identically to builtin handlers

# Dependencies

- [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) parsers:
  - [markdown & markdown_inline](https://github.com/tree-sitter-grammars/tree-sitter-markdown):
    Used to parse `markdown` files
  - [latex](https://github.com/latex-lsp/tree-sitter-latex) (Optional):
    Used to get `LaTeX` blocks from `markdown` files
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
    'MeanderingProgrammer/markdown.nvim',
    name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    config = function()
        require('render-markdown').setup({})
    end,
}
```

## packer.nvim

```lua
use({
    'MeanderingProgrammer/markdown.nvim',
    as = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
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

`:RenderMarkdownToggle` - Switch between enabling & disabling this plugin

- Function can also be accessed directly through `require('render-markdown').toggle()`

# Setup

The full default configuration is provided below for reference.

Any part of it can be modified however for many fields this does not make much sense.

Some of the more useful fields are discussed further down.

<details>

<summary>Full Default Configuration</summary>

```lua
require('render-markdown').setup({
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
        (fenced_code_block (info_string (language) @language))

        [
            (list_marker_plus)
            (list_marker_minus)
            (list_marker_star)
        ] @list_marker

        (task_list_marker_unchecked) @checkbox_unchecked
        (task_list_marker_checked) @checkbox_checked

        (block_quote) @quote

        (pipe_table) @table
        (pipe_table_header) @table_head
        (pipe_table_delimiter_row) @table_delim
        (pipe_table_row) @table_row
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
        -- Specify custom checkboxes, must be surrounded in square brackets
        custom = {
            todo = { raw = '[-]', rendered = '󰥔 ', highlight = '@markup.raw' },
        },
    },
    -- Character that will replace the > at the start of block quotes
    quote = '▋',
    -- Symbol / text to use for different callouts
    callout = {
        note = '󰋽 Note',
        tip = '󰌶 Tip',
        important = '󰅾 Important',
        warning = '󰀪 Warning',
        caution = '󰳦 Caution',
        custom = {
            bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'DiagnosticError' },
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
            -- Used when being rendered, conceal text in all modes
            rendered = 'nvic',
        },
    },
    -- Determines how code blocks are rendered
    --  full: adds language icon above code block if possible + normal behavior
    --  normal: renders a background
    --  none: disables rendering
    code_style = 'full',
    -- Determines how tables are rendered
    --  full: adds a line above and below tables + normal behavior
    --  normal: renders the rows of tables
    --  none: disables rendering
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
            foregrounds = { 'markdownH1', 'markdownH2', 'markdownH3', 'markdownH4', 'markdownH5', 'markdownH6' },
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
})
```

</details>

We use the following definitions when discussing indexing into arrays:

1. Cycle: Indexed `mod` the length.
   Example: `{ 1, 2, 3 }` @ 4 = 1.
2. Clamp: Indexed normally but larger values use the last value in the array.
   Example: `{ 1, 2, 3 }` @ 4 = 3.

## Headings

- Icon: `headings`
- Highlight: `highlights.heading.backgrounds` & `highlights.heading.backgrounds`
- Style: N/A

- The icons replace the `#` characters in front of headings
- The number of `#` characters in the heading determines the level of the heading
- The level is used to index into the icon table using a cycle
- The icon is left padded with spaces to fill the gap and hide any additional `#`
- The level is also used to index into both highlights tables using a clamp
- Both are applied to the icon and the background extends through the entire line

## Dashed Line

- Icon: `dash`
- Highlight: `highlights.dash`
- Style: N/A

- Gets repeated across the window's width when a `thematic_break` is found

## List Bullets

- Icon: `bullets`
- Highlight: `highlights.bullet`
- Style: N/A

- The icons replace the `-`, `+`, and `*` characters in front of list items
- How deeply nested the list is determines the level of the list
- The level is used to index into the icon table using a cycle
- If the item is a `checkbox` a conceal is instead used to hide the bullet

## Checkboxes

- Icon: `checkbox.unchecked`, `checkbox.checkbox`, & `checkbox.custom.rendered`
- Highlight: `highlights.checkbox.unchecked`, `highlights.checkbox.checked`, & `checkbox.custom.highlight`
- Style: N/A

- In the case of a standard checked `[x]` or unchecked `[ ]` checkbox state we simply
  overlay the appropriate icon and apply the appropriate highlight

- Custom checkbox states setup through `checkbox.custom` are more involved as they
  are not part of the actual `markdown` grammar
- As a result this requires neovim >= `0.10.0` since it relies on `inline` extmarks
- An example comes with the default config:
  `todo = { raw = '[-]', rendered = '󰥔 ', highlight = '@markup.raw' }`
- The key part in this case `todo` is unused. The parts of the value are:
  - `raw`: matched against the raw text of a `shortcut_link`
  - `rendered`: replaces the `raw` value when rendering
  - `highlight`: color used for `rendered` text

## Standard Quotes

- Icon: `quote`
- Highlight: `highlights.quote`
- Style: N/A

- The icon replaces the `|` character in front of `block_quotes`

## Callouts

- Icon: `callout` & `callout.custom.rendered`
- Highlight: `highlights.callout` & `callout.custom.highlight`
- Style: N/A

- Callouts are a special instance of a `block_quote` that start with a `shortcut_link`
- When this pattern is seen the link text gets replaced by the icon
- The highlight is then applied to the icon as well as the quote markers

- Custom callouts setup through `callout.custom` behave in much the same way
- An example comes with the default config:
  `bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'DiagnosticError' }`
- The key part in this case `bug` is unused. The parts of the value are:
  - `raw`: matched against the raw text of a `shortcut_link`
  - `rendered`: replaces the `raw` value when rendering
  - `highlight`: color used for `rendered` text

## Code Blocks

- Icon: N/A
- Highlight: `highlights.code`
- Style: `code_style`

- `code_style` determines how code blocks are rendered:
  - `none`: disables all rendering
  - `normal`: adds highlight group to the code block
  - `full`: `normal` + language icon & name above the code block

## Tables

- Icon: N/A
- Highlight: `highlights.table.head` & `highlights.table.row`
- Style: `table_style` & `cell_style`

- The `head` highlight is used for the table heading, delimitter, and the line above
- The `row` highlight is used for everything else, main table rows and the line below
- `table_style` determines how the table as a whole is rendered:
  - `none`: disables all rendering
  - `normal`: applies the `cell_style` rendering to each row of the table
  - `full`: `normal` + a top & bottom line that fill out the table when lengths match
- `cell_style` determines how individual cells of a table are rendered:
  - `overlay`: writes completely over the table, removing conceal behavior and highlights
  - `raw`: replaces only the `|` icons in each row, leaving the cell completely unmodified

# Additional Info

- [Limitations](doc/limitations.md): Known limitations of this plugin
- [Custom Handlers](doc/custom-handlers.md): Allow users to integrate custom rendering
  for either unsupported languages or to override / extend builtin implementations
- [Troubleshooting Guide](doc/troubleshooting.md)
- [Purpose](doc/purpose.md): Why this plugin exists
- [Markdown Ecosystem](doc/markdown-ecosystem.md): Information about other `markdown`
  related plugins and how they co-exist

> [!NOTE]
>
> If you use [vimwiki](https://github.com/vimwiki/vimwiki), because it overrides
> the `filetype` of `markdown` files there are additional setup steps.
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
