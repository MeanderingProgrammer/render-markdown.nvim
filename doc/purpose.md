# Purpose

There are many existing markdown rendering plugins in the Neovim ecosystem. However,
most of these rely on syncing a separate browser window with the buffer. This is
the correct way to do things to get full feature support, however I wanted something
that worked completely inside of Neovim and made things look slightly "nicer".

The closest one I found to this was [headlines.nvim](https://github.com/lukas-reineke/headlines.nvim),
which is an awesome plugin that I took several ideas from. However it just didn't
have quite what I was looking for. In particular I wanted something that would
disappear completely when editing a file and quickly render some style when viewing
the file. Hence this plugin.
