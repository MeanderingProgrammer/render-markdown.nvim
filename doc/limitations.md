# Limitations

## `block` Width Removes Column Features

[ISSUE #385](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/385)

This problem impacts both `code` & `heading` rendering when using
`{ width = 'block' }`. Regardless of how wide the actual content is all `colorcolumn`
icons will be hidden on the intersecting lines and `cursorline` will not work.

This occurs because there is no way to create a background highlight that starts
and ends at specific columns. So instead to achieve the effect we combine 2 highlights:

1. `hl_group` + `hl_eol`: results in the entire line being highlighted
2. `virt_text` with many spaces using the background highlight + `virt_text_win_col`:
   results in hiding the highlight after our target column

Why does it work like this? To explain that lets see how else we could implement
this. The starting point would be to avoid highlighting the entire line, so we don't
then need to hide the highlight. This part is easy, just remove `hl_eol = true` from
the first mark, done!

Now we have all the inner text highlighted with the background, so the problem is
now to extend each one of these so it reaches our target column.

Your first thought might be to use `virt_text_pos = 'eol'`, and do some basic math
to figure out how long to make each line. Well, unfortunately `eol` does not mean
right at the end of the line, there's actually a space that gets added before the
mark starts that we cannot get rid of, so this one is a non-starter.

Your second thought might be to use `virt_text_win_col`, but set it to be right after
each line, after that it's the same as the previous approach. To make this work we
need to compute the width of each line exactly. If we make it one too large we'll
have an empty space, too small and we'll cut off text in the code block. To do this
correctly we'll need to properly handle concealed ranges for all of the code blocks.
This isn't impossible but it is slow and error prone since we also need to handle
the odd case where another `markdown` block is nested.

To avoid all this additional complexity we take the approach of using 2 highlights
which works because the simple string width calculation is if anything going to be
an over-estimate which is not really a big deal, just adds some extra padding in
the worst case but the block remains contiguous.

The `colorcolumn` will also be missing on any `virt_lines` marks. This applies to
the lines above and below pipe tables, heading borders, latex formulas, and potentially
others added after the time of writing. With this limitation we have no way around
it other than re-implementing `colorcolumn` in this plugin, which is not something
the author has any interest in doing. Ideally neovim would be able to detect new
virtual lines and apply the `colorcolumn` to them, I do not believe there is any
intentions to do this since virtual lines exist mostly outside the standard buffer.

Below are a few things to try out to improve the aesthetic:

- Use `win_options` to disable `colorcolumn` when rendering, this is my personal
  favorite since `colorcolumn` is really only helpful when editing

```lua
require('render-markdown').setup({
    win_options = {
        colorcolumn = { default = vim.o.colorcolumn, rendered = '' },
    },
})
```

- Set the `min_width` options to the same value as `colorcolumn`

```lua
require('render-markdown').setup({
    heading = { width = 'block', min_width = tonumber(vim.o.colorcolumn) },
    code = { width = 'block', min_width = tonumber(vim.o.colorcolumn) },
})
```

- Do not use `block` width, keep the default value of `full`

```lua
require('render-markdown').setup({
    heading = { width = 'full' },
    code = { width = 'full' },
})
```

## `latex` Formula Positioning

[ISSUE #6](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/6)

`latex` formula evaluations are placed above text rather than overlaid.

A way around this is to use a separate plugin for `latex` and disable that feature
in this plugin. Different plugins will have different setups, below are some examples:

[latex.nvim](https://github.com/ryleelyman/latex.nvim)

```lua
{
    { 'ryleelyman/latex.nvim', opts = {} },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
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
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
        opts = {
            latex = { enabled = false },
            win_options = { conceallevel = { rendered = 2 } },
            on = {
                render = function()
                    require('nabla').enable_virt({ autogen = true })
                end,
                clear = function()
                    require('nabla').disable_virt()
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
