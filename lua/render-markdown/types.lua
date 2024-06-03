---@class render.md.Callout
---@field public note string
---@field public tip string
---@field public important string
---@field public warning string
---@field public caution string

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
---@field public callout render.md.Callout

---@class render.md.Checkbox
---@field public unchecked string
---@field public checked string

---@class render.md.Config
---@field public start_enabled boolean
---@field public max_file_size number
---@field public markdown_query string
---@field public inline_query string
---@field public latex_converter string
---@field public log_level 'debug'|'error'
---@field public file_types string[]
---@field public render_modes string[]
---@field public headings string[]
---@field public dash string
---@field public bullets string[]
---@field public checkbox render.md.Checkbox
---@field public quote string
---@field public callout render.md.Callout
---@field public win_options table<string, render.md.WindowOption>
---@field public table_style 'full'|'normal'|'none'
---@field public custom_handlers table<string, render.md.Handler>
---@field public highlights render.md.Highlights
