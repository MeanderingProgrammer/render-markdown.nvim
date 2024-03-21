# markdown.nvim

Plugin to improve viewing Markdown files in Neovim

Plugin is experimental at this time

# Features

- Changes between `rendered` view in normal mode (exact modes are configurable)
  and raw view in all other modes
- Highlights headings with different groups depending on level
- Highlights code blocks to better stand out
- Replaces whichever style bullet point is being used with provided character
- Updates table boarders with better boarder characters, does NOT automatically align

# Dependencies

- [markdown](https://github.com/tree-sitter-grammars/tree-sitter-markdown) parser for
  [treesitter](https://github.com/nvim-treesitter/nvim-treesitter): Used to parse
  `markdown` files

# Install

## Lazy.nvim

```lua
{
    'MeanderingProgrammer/markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
        require('markdown').setup({})
    end,
}
```

## Default Config

Below is the configuration that gets used by default, any part of it can be modified
by the user.

```lua
require('markdown').setup({
    -- Capture groups that get pulled from the markdown file, these are later
    -- used to modify how the file gets rendered
    query = vim.treesitter.query.parse(
        'markdown',
        [[
            (atx_heading [
                (atx_h1_marker)
                (atx_h2_marker)
                (atx_h3_marker)
                (atx_h4_marker)
                (atx_h5_marker)
                (atx_h6_marker)
            ] @heading)

            (fenced_code_block) @code

            (list_item) @item

            (pipe_table_header) @table_head
            (pipe_table_delimiter_row) @table_delim
            (pipe_table_row) @table_row
        ]]
    ),
    -- vim modes that will show a rendered view of the markdown file, all other
    -- modes will be uneffected by this plugin
    render_modes = { 'n', 'c' },
    -- Character to use for the bullet point in lists
    bullet = '○',
    highlights = {
        -- Groups that get cycled through for rendering headings
        headings = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
        -- Used when displaying code blocks
        code = 'ColorColumn',
        -- Used when displaying bullet points in list
        bullet = 'Normal',
        table = {
            -- Used when displaying header in a markdown table
            head = '@markup.heading',
            -- Used when displaying non header rows in a markdown table
            row = 'Normal',
        },
    },
})
```

# Related Projects

- [headlines.nvim](https://github.com/lukas-reineke/headlines.nvim) - Same high level 
  idea different features
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) - Uses browser
- [vim-markdown-composer](https://github.com/euclio/vim-markdown-composer) - Uses browser
