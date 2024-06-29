# Custom Handlers

Custom handlers allow users to integrate custom rendering for either unsupported
languages or to override / extend builtin implementations.

Custom handlers are ran identically to builtin ones, so by writing custom `extmark`s
(see :h nvim_buf_set_extmark()) to the `namespace` this plugin will handle clearing
the `extmark`s on mode changes as well as re-rendering when needed.

## Interface

Each handler must conform to the following interface:

```lua
---@class render.md.Handler
---@field public render fun(namespace: integer, root: TSNode, buf: integer)
---@field public extends? boolean
```

The `render` function parameters are:

- `namespace`: The id that this plugin interacts with when setting and clearing `extmark`s
- `root`: The root treesitter node for the specified language
- `buf`: The buffer containing the root node

The `extends` parameter defines whether the builtin handler should still be run in
conjunction with this one. Defaults to `false`.

This is a high level interface, as such creating, parsing, and iterating through
a treesitter query is entirely up to the user if the functionality they want needs
this. We do not provide any convenience functions, but you are more than welcome
to use patterns from the builtin handlers.

## Example 1: Disable a Builtin

By not specifying the `extends` field and leaving the `render` implementation blank
we can disable a builtin handler. Though this has little benefit and can be accomplished
in other ways such as setting `{ latex_enabled = false }` for `LaTeX`.

Still as a toy example disabling the `LaTeX` handler can be done with:

```lua
require('render-markdown').setup({
    custom_handlers = {
        latex = { render = function() end },
    },
}
```

## Example 2: Highlight `python` Function Definitions

This will require a treesitter query and using the range values of nodes.

```lua
-- Parse query outside of the render function to avoid doing it for each call
local query = vim.treesitter.query.parse('python', '(function_definition) @def')
local function render_pyth    for id, node in query:iter_captures(root, buf) do
        local capture = query.captures[id]
        local start_row, _, _, _ = node:range()
        if capture == 'def' then
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, 0, {
                end_row = start_row + 1,
                end_col = 0,
                hl_group = 'DiffDelete',
                hl_eol = true,
            })
        end
    end
end
require('render-markdown').setup({
    custom_handlers = {
        python = { render = render_python },
    },
}
```
