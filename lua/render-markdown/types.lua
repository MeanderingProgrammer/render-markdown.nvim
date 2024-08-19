---@meta

---@class (exact) render.md.Latex
---@field public enabled boolean
---@field public converter string
---@field public highlight string
---@field public top_pad integer
---@field public bottom_pad integer

---@class (exact) render.md.WindowOption
---@field public default number|string|boolean
---@field public rendered number|string|boolean

---@class (exact) render.md.Sign
---@field public enabled boolean
---@field public highlight string

---@class (exact) render.md.LinkComponent
---@field public pattern string
---@field public icon string
---@field public highlight string

---@class (exact) render.md.Link
---@field public enabled boolean
---@field public image string
---@field public hyperlink string
---@field public highlight string
---@field public custom table<string, render.md.LinkComponent>

---@class (exact) render.md.PipeTable
---@field public enabled boolean
---@field public preset render.md.table.Preset
---@field public style render.md.table.Style
---@field public cell render.md.table.Cell
---@field public border string[]
---@field public alignment_indicator string
---@field public head string
---@field public row string
---@field public filler string

---@class (exact) render.md.CustomComponent
---@field public raw string
---@field public rendered string
---@field public highlight string

---@class (exact) render.md.Quote
---@field public enabled boolean
---@field public icon string
---@field public repeat_linebreak boolean
---@field public highlight string

---@class (exact) render.md.CheckboxComponent
---@field public icon string
---@field public highlight string

---@class (exact) render.md.Checkbox
---@field public enabled boolean
---@field public unchecked render.md.CheckboxComponent
---@field public checked render.md.CheckboxComponent
---@field public custom table<string, render.md.CustomComponent>

---@class (exact) render.md.Bullet
---@field public enabled boolean
---@field public icons string[]
---@field public left_pad integer
---@field public right_pad integer
---@field public highlight string

---@class (exact) render.md.Dash
---@field public enabled boolean
---@field public icon string
---@field public width 'full'|integer
---@field public highlight string

---@class (exact) render.md.Code
---@field public enabled boolean
---@field public sign boolean
---@field public style render.md.code.Style
---@field public position render.md.code.Position
---@field public disable_background string[]
---@field public width render.md.code.Width
---@field public left_pad integer
---@field public right_pad integer
---@field public language_pad? integer
---@field public min_width integer
---@field public border render.md.code.Border
---@field public above string
---@field public below string
---@field public highlight string
---@field public highlight_inline string

---@class (exact) render.md.Heading
---@field public enabled boolean
---@field public sign boolean
---@field public position render.md.heading.Position
---@field public icons string[]
---@field public signs string[]
---@field public width render.md.heading.Width|(render.md.heading.Width)[]
---@field public left_pad integer
---@field public right_pad integer
---@field public min_width integer
---@field public border boolean
---@field public border_prefix boolean
---@field public above string
---@field public below string
---@field public backgrounds string[]
---@field public foregrounds string[]

---@class (exact) render.md.AntiConceal
---@field public enabled boolean
---@field public above integer
---@field public below integer

---@class (exact) render.md.ConfigOverrides
---@field public buftype table<string, render.md.UserBufferConfig>

---@class (exact) render.md.BufferConfig
---@field public enabled boolean
---@field public max_file_size number
---@field public debounce integer
---@field public render_modes string[]
---@field public anti_conceal render.md.AntiConceal
---@field public heading render.md.Heading
---@field public code render.md.Code
---@field public dash render.md.Dash
---@field public bullet render.md.Bullet
---@field public checkbox render.md.Checkbox
---@field public quote render.md.Quote
---@field public pipe_table render.md.PipeTable
---@field public callout table<string, render.md.CustomComponent>
---@field public link render.md.Link
---@field public sign render.md.Sign
---@field public win_options table<string, render.md.WindowOption>

---@class (exact) render.md.Config: render.md.BufferConfig
---@field public preset render.md.config.Preset
---@field public markdown_query string
---@field public markdown_quote_query string
---@field public inline_query string
---@field public log_level render.md.config.LogLevel
---@field public file_types string[]
---@field public acknowledge_conflicts boolean
---@field public latex render.md.Latex
---@field public overrides render.md.ConfigOverrides
---@field public custom_handlers table<string, render.md.Handler>
