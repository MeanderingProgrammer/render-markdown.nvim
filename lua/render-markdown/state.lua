---@class TableHighlights
---@field public head string
---@field public row string

---@class HeadingHighlights
---@field public backgrounds string[]
---@field public foregrounds string[]

---@class Highlights
---@field public heading HeadingHighlights
---@field public code string
---@field public bullet string
---@field public table TableHighlights
---@field public latex string
---@field public quote string

---@class Conceal
---@field public default integer
---@field public rendered integer

---@class Config
---@field public markdown_query string
---@field public inline_query string
---@field public file_types string[]
---@field public render_modes string[]
---@field public headings string[]
---@field public bullet string
---@field public quote string
---@field public conceal Conceal
---@field public fat_tables boolean
---@field public highlights Highlights

---@class State
---@field enabled boolean
---@field config Config
---@field markdown_query Query
---@field inline_query Query
local state = {}
return state
