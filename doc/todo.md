# TODOs

- See if there is a stable way to align table cells according to delimiter
  alignment info.
- Figure out how to display the many configuration options & impact
- Potentially change LuaRocks icon dependency to [mini.icons](https://luarocks.org/modules/neorocks/mini.icons)
- Force non-markdown handlers to run first in `ui.lua`. Cache information
  at buffer level from inline parser to avoid computing it:

```lua
-- Parse marks
local marks = {}
-- Parse markdown after all other nodes to take advantage of state
local markdown_roots = {}
parser:for_each_tree(function(tree, language_tree)
    local language = language_tree:lang()
    if language == 'markdown' then
        table.insert(markdown_roots, tree:root())
    else
        vim.list_extend(marks, M.parse_tree(buf, language, tree:root()))
    end
end)
for _, root in ipairs(markdown_roots) do
    vim.list_extend(marks, M.parse_tree(buf, 'markdown', root))
end
return marks
```
