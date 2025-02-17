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

## Validate Configuration

This is only a potential issue if you are using a distribution, as opposed to your
own configuration. The configuration for this plugin could be set by the distribution
to some default the author prefers. So the settings you think you are using are not
necessarily the only ones be used.

Run `:RenderMarkdown config`, which will output only the non-default values being
used, you might be surprised what you find.

## Validate Parse Tree

Create a new `markdown` file locally with the following content:

```text
# Heading

- Item

> [!NOTE]
> A note

- [x] Checked
```

Run `:InspectTree` which should output the following:

```text
(document ; [0, 0] - [8, 0]
  (section ; [0, 0] - [8, 0]
    (atx_heading ; [0, 0] - [1, 0]
      (atx_h1_marker) ; [0, 0] - [0, 1]
      heading_content: (inline ; [0, 2] - [0, 9]
        (inline))) ; [0, 2] - [0, 9]
    (list ; [2, 0] - [4, 0]
      (list_item ; [2, 0] - [4, 0]
        (list_marker_minus) ; [2, 0] - [2, 2]
        (paragraph ; [2, 2] - [3, 0]
          (inline ; [2, 2] - [2, 6]
            (inline)) ; [2, 2] - [2, 6]
          (block_continuation)))) ; [3, 0] - [3, 0]
    (block_quote ; [4, 0] - [6, 0]
      (block_quote_marker) ; [4, 0] - [4, 2]
      (paragraph ; [4, 2] - [6, 0]
        (inline ; [4, 2] - [5, 8]
          (inline ; [4, 2] - [5, 8]
            (shortcut_link ; [4, 2] - [4, 9]
              (link_text))) ; [4, 3] - [4, 8]
          (block_continuation)))) ; [5, 0] - [5, 2]
    (list ; [7, 0] - [8, 0]
      (list_item ; [7, 0] - [8, 0]
        (list_marker_minus) ; [7, 0] - [7, 2]
        (task_list_marker_checked) ; [7, 2] - [7, 5]
        (paragraph ; [7, 6] - [8, 0]
          (inline ; [7, 6] - [7, 13]
            (inline))))))) ; [7, 6] - [7, 13]
```

If this is not what you see you likely need to update `nvim-treesitter` and your
treesitter parsers.

## Generate Debug Logs

If all else fails hopefully the logs can provide some insight. This plugin
ships with logging, however it only includes errors by default.

To help debug your issue you'll need to go through the following steps:

### 1) Create a Test File

Use the same file from [Validate Parse Tree](#validate-parse-tree).

### 2) Update Log Level

Change plugin configuration to output `debug` logs:

```lua
require('render-markdown').setup({
    log_level = 'debug',
})
```

### 3) Generate Logs

To do this restart Neovim and open the `markdown` file from the first step.

This should trigger the rendering logic, then close Neovim.

### 4) Provide Logs in Issue

Logs can be retrieved by running `:RenderMarkdown log`.

Copy the contents and paste them into the issue.
