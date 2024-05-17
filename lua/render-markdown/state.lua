---@class render.md.TableHighlights
---@field public head string
---@field public row string

---@class render.md.CheckboxHighlights
---@field public unchecked string
---@field public checked string

---@class render.md.HeadingHighlights
---@field public backgrounds string[]
---@field public foregrounds string[]

---@class render.md.Highlights
---@field public heading render.md.HeadingHighlights
---@field public dash string
---@field public code string
---@field public bullet string
---@field public checkbox render.md.CheckboxHighlights
---@field public table render.md.TableHighlights
---@field public latex string
---@field public quote string

---@class render.md.Conceal
---@field public default integer
---@field public rendered integer

---@class render.md.Checkbox
---@field public unchecked string
---@field public checked string

---@class render.md.Config
---@field public start_enabled boolean
---@field public max_file_size number
---@field public markdown_query string
---@field public inline_query string
---@field public log_level 'debug'|'error'
---@field public file_types string[]
---@field public render_modes string[]
---@field public headings string[]
---@field public dash string
---@field public bullets string[]
---@field public checkbox render.md.Checkbox
---@field public quote string
---@field public conceal render.md.Conceal
---@field public fat_tables boolean
---@field public highlights render.md.Highlights

---@class render.md.State
---@field config render.md.Config
---@field enabled boolean
---@field markdown_query vim.treesitter.Query
---@field inline_query vim.treesitter.Query
local state = {}
return state
