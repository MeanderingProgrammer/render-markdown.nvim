# Troubleshooting

The following guide goes from easy to complex operations that can help when this
plugin is not functioning how you expect. As such it is recommended to go in order.

## Run checkhealth

```vim
:checkhealth render-markdown
```

If there are any `errors` these should be looked at closely, `warnings` can largely
be ignored. They are generated to help debug issues for less critical components,
i.e. `LaTeX` support.

## Validate `filetype`

This plugin only operates on `markdown` files by default, but can be expanded to
run on any filetype with `markdown` injected by providing it in the config:

```lua
require('render-markdown').setup({
    file_types = { 'markdown', <other_filetype> },
})
```

Once you confirm the list of `filetypes` you expect this plugin to work on get
the `filetype` of the current buffer and make sure it is in that list:

```vim
:lua vim.print(vim.bo.filetype)
```

## Generating debug logs

If all else fails hopefully the logs can provide some insight. This plugin
ships with logging, however it only includes errors by default.

To help debug your issue you'll need to go through the following steps:

1. Update the log level to `debug`
2. Create a test file
3. Generate logs from the test file
4. Provide the logs in the issue

### Update the log level to `debug`

Change the plugin configuration to:

```lua
require('render-markdown').setup({
    log_level = 'debug',
})
```

### Create a test file

Create a new `markdown` file locally with the following content:

```text
# Heading

- Item
  - Nested

> [!NOTE]
> A note

- [ ] Unchecked
- [x] Checked
```

### Generate logs from the test file

To do this restart Neovim and open the `markdown` file from the previous step.

This should trigger the render function by default, then close Neovim.

### Provide the logs in the issue

Logs are written to a file typically located at: `~/.local/state/nvim/render-markdown.log`.

Copy the contents of that file and paste it into the issue.
