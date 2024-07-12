# Limitations

## Text Boundaries

[ISSUE #35](https://github.com/MeanderingProgrammer/markdown.nvim/issues/35)

Text that extends beyond available space will can overwrite content.

This has been fixed for headings when using neovim >= `0.10.0`.

## `LaTeX` Formula Positioning

[ISSUE #6](https://github.com/MeanderingProgrammer/markdown.nvim/issues/6)

`LaTeX` formula evaluations are placed above text rather than overlayed.

## Which Key Limiting Modes

[ISSUE #43](https://github.com/MeanderingProgrammer/markdown.nvim/issues/43)

Since `which-key` interjects when writing commands it can effectively limit the
number of modes available to the user.

This varies by configuration. An example is having the `operators` preset enabled
will prevent the user from entering the operator pending mode. Since this mode cannot
be reached this plugin cannot not do anything special in the operator pending state,
since it effectively does not exist.

This is expected behavior by `which-key`: [ISSUE #534](https://github.com/folke/which-key.nvim/issues/534)

## Telescope Opening File

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
