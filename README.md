# markdown.nvim

Plugin to improve viewing Markdown files in Neovim

![Demo](demo/demo.gif)

# Features

- Functions entirely inside of Neovim with no external windows
- Changes between `rendered` view in normal mode and raw view in all other modes
- Highlights headings with different groups depending on level and replaces `#`
- Highlights code blocks to better stand out
- Replaces whichever style bullet point is being used with provided character
- Updates table borders with better border characters, does NOT automatically align

# Dependencies

- [markdown](https://github.com/tree-sitter-grammars/tree-sitter-markdown) parser for
  [treesitter](https://github.com/nvim-treesitter/nvim-treesitter): Used to parse
  `markdown` files

# Install

## Lazy.nvim

```lua
{
    'MeanderingProgrammer/markdown.nvim',
    name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
        require('render-markdown').setup({})
    end,
}
```

## Default Config

Below is the configuration that gets used by default, any part of it can be modified
by the user.

```lua
require('render-markdown').setup({
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
    -- Characters that will replace the # at the start of markdown headings
    headings = { '󰲡', '󰲣', '󰲥', '󰲧', '󰲩', '󰲫' },
    -- Character to use for the bullet point in lists
    bullet = '○',
    highlights = {
        heading = {
            -- Used for rendering heading line backgrounds
            backgrounds = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
            -- Used for rendering the foreground of the heading character only
            foregrounds = {
                'markdownH1',
                'markdownH2',
                'markdownH3',
                'markdownH4',
                'markdownH5',
                'markdownH6',
            },
        },
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

# Purpose

There are many existing markdown rendering plugins in the Neovim ecosystem. However,
most of these rely on syncing a separate browser window with the buffer. This is the
correct way to do things to get full feature support, however I wanted something that
worked completely inside of Neovim and made things look slightly "nicer".

The closest one I found to this was [headlines.nvim](https://github.com/lukas-reineke/headlines.nvim),
which is an awesome plugin that I took several ideas from. However it just didn't have
quite what I was looking for. In particular I wanted something that would disappear completely
when editing a file and quickly render some style when viewing the file. Hence this plugin.

# Related Projects

- [headlines.nvim](https://github.com/lukas-reineke/headlines.nvim) - Same high level 
  idea different features
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) - Uses browser
- [vim-markdown-composer](https://github.com/euclio/vim-markdown-composer) - Uses browser
