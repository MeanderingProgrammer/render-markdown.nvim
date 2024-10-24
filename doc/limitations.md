# Limitations

## `LaTeX` Formula Positioning

[ISSUE #6](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/6)

`LaTeX` formula evaluations are placed above text rather than overlaid.

A way around this is to use a separate plugin for `LaTeX` and disable that feature
in this plugin. Different plugins will have different setups, below are some examples:

[latex.nvim](https://github.com/ryleelyman/latex.nvim)

```lua
{
    { 'ryleelyman/latex.nvim', opts = {} },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
        opts = {
            latex = { enabled = false },
            win_options = { conceallevel = { rendered = 2 } },
        },
    },
}
```

[nabla.nvim](https://github.com/jbyuki/nabla.nvim)

```lua
{
    { 'jbyuki/nabla.nvim' },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
        opts = {
            latex = { enabled = false },
            win_options = { conceallevel = { rendered = 2 } },
            on = {
                attach = function()
                    require('nabla').enable_virt({ autogen = true })
                end,
            },
        },
    },
}
```

> [!NOTE]
>
> These plugins can rely on a specific `conceallevel` to work properly, which
> you will need to configure in this plugin like in the examples above.

## Does Not Run in Telescope Preview

[ISSUE #98](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/98)

Telescope has a special way of previewing files that does not work like a
standard buffer: [info](https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#previewers)

Due to this the events this plugin relies on to attach to and render buffers
do not get triggered.

# Resolved Limitations

## Telescope Opening File

[FIX 4ab8359](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/4ab835985de62b46b6785ae160f5f709b77a0f92)

Should no longer be an issue on any version of neovim if up to date.

Since `telescope` performs several mode change operations to enable previewing and
other nice things like setting `marks` when changing buffers there are scenarios
where a `markdown` file will not render when it is initially opened through `telescope`.

An example of this is when opening a file using `live_grep` and default settings.
The issue stems from `telescope` running two `normal` mode commands in the process
of opening a file. At the time of writing these are:

- Center preview windows on the correct line: [here](https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/previewers/buffer_previewer.lua#L549)
- Set a `mark` prior to opening a file: [here](https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/actions/set.lua#L177)

Something about the way these are done causes the file to appear be opened in `insert`
mode despite being in `normal` mode. Additionally there is no `ModeChanged` event
that occurs after this to go back to `normal` mode.

## Text Boundaries

[FIX 5ce3566](https://github.com/MeanderingProgrammer/render-markdown.nvim/commit/5ce35662725b1024c6dddc8d0bc03befc5abc878)

Should no longer be an issue when using neovim >= `0.10.0`.

[ISSUE #35](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/35)

Text that extends beyond available space will can overwrite content.

## Which Key Limiting Modes

This is no longer the case as of `which-key` v3 release.

[ISSUE #43](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/43)

Since `which-key` interjects when writing commands it can effectively limit the
number of modes available to the user.

This varies by configuration. An example is having the `operators` preset enabled
will prevent the user from entering the operator pending mode. Since this mode cannot
be reached this plugin cannot not do anything special in the operator pending state,
since it effectively does not exist.

This is expected behavior by `which-key`: [ISSUE #534](https://github.com/folke/which-key.nvim/issues/534)
