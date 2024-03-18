# markdown.nvim

Plugin to improve viewing Markdown files in Neovim

# Features

- Changes between `rendered` view in normal mode (exact modes are configurable)
  and raw view in all other modes
- Highlights headings with different groups depending on level
- Highlights code blocks to better stand out
- Replaces whichever style bullet point is being used with provided character

# Dependencies

- [markdown](https://github.com/tree-sitter-grammars/tree-sitter-markdown/tree/split_parser)
  parser for [treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/master):
  Used to parse `markdown` files

# Install

WIP

## Lazy.nvim

```lua
{
    'MeanderingProgrammer/markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
        require('markdown').setup({
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
                ]]
            ),
            render_modes = { 'n', 'c' },
            bullet = '○',
            highlights = {
                headings = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
                code = 'ColorColumn',
                bullet = 'Normal',
            },
        })
    end,
}
```

# Related Projects

- [headlines.nvim](https://github.com/lukas-reineke/headlines.nvim) - Same high level 
  idea different features
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) - Uses browser
- [vim-markdown-composer](https://github.com/euclio/vim-markdown-composer) - Uses browser
