---@class TableHighlights
---@field public head string
---@field public row string

---@class Highlights
---@field public headings string[]
---@field public code string
---@field public bullet string
---@field public table TableHighlights

---@class Config
---@field public query Query
---@field public render_modes string[]
---@field public bullet string
---@field public highlights Highlights

---@class State
---@field config Config
local state = {}
return state
