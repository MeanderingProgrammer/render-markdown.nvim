---@class render.md.PipeTable
---@field public style 'full'|'normal'|'none'
---@field public cell 'overlay'|'raw'
---@field public boarder string[]
---@field public head string
---@field public row string

---@class render.md.CustomComponent
---@field public raw string
---@field public rendered string
---@field public highlight string

---@class render.md.Checkbox
---@field public unchecked render.md.BasicComponent
---@field public checked render.md.BasicComponent
---@field public custom table<string, render.md.CustomComponent>

---@class render.md.Bullet
---@field public icons string[]
---@field public highlight string

---@class render.md.BasicComponent
---@field public icon string
---@field public highlight string

---@class render.md.Code
---@field public style 'full'|'normal'|'language'|'none'
---@field public highlight string

---@class render.md.Heading
---@field public icons string[]
---@field public signs string[]
---@field public backgrounds string[]
---@field public foregrounds string[]

---@class render.md.Latex
---@field public enabled boolean
---@field public converter string
---@field public highlight string

---@class render.md.Config
---@field public enabled boolean
---@field public max_file_size number
---@field public markdown_query string
---@field public markdown_quote_query string
---@field public inline_query string
---@field public log_level 'debug'|'error'
---@field public file_types string[]
---@field public render_modes string[]
---@field public latex render.md.Latex
---@field public heading render.md.Heading
---@field public code render.md.Code
---@field public dash render.md.BasicComponent
---@field public bullet render.md.Bullet
---@field public checkbox render.md.Checkbox
---@field public quote render.md.BasicComponent
---@field public pipe_table render.md.PipeTable
---@field public callout table<string, render.md.CustomComponent>
---@field public win_options table<string, render.md.WindowOption>
---@field public custom_handlers table<string, render.md.Handler>
