---@class TableHighlights
---@field public head string
---@field public row string

---@class CheckboxHighlights
---@field public unchecked string
---@field public checked string

---@class HeadingHighlights
---@field public backgrounds string[]
---@field public foregrounds string[]

---@class Highlights
---@field public heading HeadingHighlights
---@field public dash string
---@field public code string
---@field public bullet string
---@field public checkbox CheckboxHighlights
---@field public table TableHighlights
---@field public latex string
---@field public quote string

---@class Conceal
---@field public default integer
---@field public rendered integer

---@class Checkbox
---@field public unchecked string
---@field public checked string

---@class Config
---@field public start_enabled boolean
---@field public markdown_query string
---@field public inline_query string
---@field public log_level 'debug'|'error'
---@field public file_types string[]
---@field public render_modes string[]
---@field public headings string[]
---@field public dash string
---@field public bullets string[]
---@field public checkbox Checkbox
---@field public quote string
---@field public conceal Conceal
---@field public fat_tables boolean
---@field public highlights Highlights

---@class State
---@field config Config
---@field enabled boolean
---@field markdown_query vim.treesitter.Query
---@field inline_query vim.treesitter.Query
local state = {}
return state
