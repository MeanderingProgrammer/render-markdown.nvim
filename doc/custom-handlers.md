# Custom Handlers

Custom handlers allow users to integrate custom rendering for either unsupported
languages or to override / extend builtin implementations.

Custom handlers are ran identically to builtin ones, so by returning `extmark` data
this plugin will handle clearing the `extmark`s on mode changes, re-rendering when
needed, and concealing when the cursor enters.

## Interface

Each handler must conform to the following interface:

```lua
---@class (exact) render.md.Handler
---@field extends? boolean
---@field parse fun(ctx: render.md.handler.Context): render.md.Mark[]

---@class (exact) render.md.handler.Context
---@field buf integer
---@field root TSNode

---@class (exact) render.md.Mark
---@field conceal boolean
---@field start_row integer
---@field start_col integer
---@field opts render.md.mark.Opts

---@class render.md.mark.Opts: vim.api.keyset.set_extmark
---@field hl_mode? 'replace'|'combine'|'blend'
---@field virt_text? render.md.mark.Line
---@field virt_text_pos? 'eol'|'inline'|'overlay'
---@field virt_lines? render.md.mark.Line[]

---@alias render.md.mark.Line render.md.mark.Text[]

---@class (exact) render.md.mark.Text
---@field [1] string text
---@field [2] string|string[] highlights
```

The `parse` function takes a `ctx` parameter whose fields are:

- `buf`: The buffer containing the root node
- `root`: The root treesitter node for the specified language

The `extends` parameter defines whether the builtin handler should still be run in
conjunction with this one. Defaults to `false`.

This is a high level interface, as such creating, parsing, and iterating through
a treesitter query is entirely up to the user if the functionality they want needs
this. We do not provide any convenience functions, but you are more than welcome
to use patterns from the builtin handlers.

For each `mark` in the return value the fields mean:

- `conceal`: determines if the mark should be hidden when cursor enters
- `start_row`: only value used to check whether cursor is inside the `mark`
- `start_col`: passed to `nvim_buf_set_extmark` as the 3rd argument
- `opts`: passed directly to `nvim_buf_set_extmark`, no special handling

## Example 1: Disable a Builtin

By not specifying the `extends` field and having the `parse` implementation return
an empty table we can disable a builtin handler. Though this has little benefit and
can be accomplished in other ways like setting `{ latex = { enabled = false } }`
for `latex`.

Still as a toy example disabling the `latex` handler can be done with:

```lua
require('render-markdown').setup({
    custom_handlers = {
        latex = {
            parse = function()
                return {}
            end,
        },
    },
})
```

## Example 2: Highlight `python` Function Definitions

This will require a treesitter query and using the range values of nodes.

```lua
-- Parse query outside of the function to avoid doing it for each call
local query = vim.treesitter.query.parse('python', '(function_definition) @def')
local function parse_python(ctx)
    local marks = {}
    for id, node in query:iter_captures(ctx.root, ctx.buf) do
        local capture = query.captures[id]
        local start_row = node:range()
        if capture == 'def' then
            marks[#marks + 1] = {
                conceal = true,
                start_row = start_row,
                start_col = 0,
                opts = {
                    end_row = start_row + 1,
                    end_col = 0,
                    hl_group = 'DiffDelete',
                    hl_eol = true,
                },
            })
        end
    end
    return marks
end
require('render-markdown').setup({
    file_types = { 'markdown', 'python' },
    custom_handlers = {
        python = { parse = parse_python },
    },
})
```
