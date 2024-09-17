# Markdown Ecosystem

There are many `markdown` plugins that specialize in different aspects of interacting
with `markdown` files. This plugin specializes in rendering the buffer inside of
Neovim, for instance. As a result some plugins will clash with this one, whereas
other plugins handle orthogonal concerns and can be used in addition to this one.
Below is a categorized (incomplete) list of available plugins.

## Render in Neovim

Using any of these plugins with this one will likely lead to undesired behavior as
different functionality will clash.

- [lukas-reineke/headlines.nvim](https://github.com/lukas-reineke/headlines.nvim)
  Same high level idea and starting point of this plugin, different feature sets
- [epwalsh/obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) While this plugin
  has many more `obsidian` related features it also provides a UI enabled by
  default that clashes with this plugin
- [OXY2DEV/markview.nvim](https://github.com/OXY2DEV/markview.nvim) An offshoot of
  this plugin with different style choices

## Render in Browser

These can be used as a second pass to get a real preview of the `markdown` file.
Since they do not interact with the buffer directly there should be no issues.

- [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
- [euclio/vim-markdown-composer](https://github.com/euclio/vim-markdown-composer)

## Orthogonal

These plugins handle functions completely separate from rendering and should also
have no issues running alongside this plugin.

- Any LSP which provides standard LSP capabilities, such as:
  - [marksman](https://github.com/artempyanykh/marksman) General completion, definition,
    and reference functionality
  - [markdown-oxide](https://github.com/Feel-ix-343/markdown-oxide) Adds Obsidian
    PKM features to LSP
- [tadmccorkle/markdown.nvim](https://github.com/tadmccorkle/markdown.nvim) Adds
  keybindings and commands for interacting with `markdown`
- [preservim/vim-markdown](https://github.com/preservim/vim-markdown) Adds syntax
  highlighting and keybindings for interacting with `markdown`
