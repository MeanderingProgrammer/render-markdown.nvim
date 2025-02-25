---@meta

---@class (exact) render.md.Callback
---@field public attach fun(ctx: render.md.CallbackContext)
---@field public render fun(ctx: render.md.CallbackContext)

---@class (exact) render.md.Injection
---@field public enabled boolean
---@field public query string

---@class (exact) render.md.WindowOption
---@field public default render.md.option.Value
---@field public rendered render.md.option.Value

---@class (exact) render.md.BaseComponent
---@field public enabled boolean
---@field public render_modes render.md.Modes

---@class (exact) render.md.HtmlComment
---@field public conceal boolean
---@field public text? string
---@field public highlight string

---@class (exact) render.md.Html: render.md.BaseComponent
---@field public comment render.md.HtmlComment
---@field public tag table<string, render.md.HtmlTag>

---@class (exact) render.md.Latex: render.md.BaseComponent
---@field public converter string
---@field public highlight string
---@field public position render.md.latex.Position
---@field public top_pad integer
---@field public bottom_pad integer

---@class (exact) render.md.Indent: render.md.BaseComponent
---@field public per_level integer
---@field public skip_level integer
---@field public skip_heading boolean
---@field public icon string
---@field public highlight string

---@class (exact) render.md.InlineHighlight: render.md.BaseComponent
---@field public highlight string

---@class (exact) render.md.Sign
---@field public enabled boolean
---@field public highlight string

---@class (exact) render.md.LinkComponent
---@field public pattern string
---@field public icon string
---@field public highlight? string

---@class (exact) render.md.WikiLink
---@field public icon string
---@field public body fun(ctx: render.md.LinkContext): string?
---@field public highlight string

---@class (exact) render.md.Footnote
---@field public superscript boolean
---@field public prefix string
---@field public suffix string

---@class (exact) render.md.Link: render.md.BaseComponent
---@field public footnote render.md.Footnote
---@field public image string
---@field public email string
---@field public hyperlink string
---@field public highlight string
---@field public wiki render.md.WikiLink
---@field public custom table<string, render.md.LinkComponent>

---@class (exact) render.md.CustomCallout
---@field public raw string
---@field public rendered string
---@field public highlight string
---@field public quote_icon? string

---@class (exact) render.md.PipeTable: render.md.BaseComponent
---@field public preset render.md.table.Preset
---@field public style render.md.table.Style
---@field public cell render.md.table.Cell
---@field public padding integer
---@field public min_width integer
---@field public border string[]
---@field public alignment_indicator string
---@field public head string
---@field public row string
---@field public filler string

---@class (exact) render.md.Quote: render.md.BaseComponent
---@field public icon string
---@field public repeat_linebreak boolean
---@field public highlight string

---@class (exact) render.md.CustomCheckbox
---@field public raw string
---@field public rendered string
---@field public highlight string
---@field public scope_highlight? string

---@class (exact) render.md.CheckboxComponent
---@field public icon string
---@field public highlight string
---@field public scope_highlight? string

---@class (exact) render.md.Checkbox: render.md.BaseComponent
---@field public position render.md.checkbox.Position
---@field public unchecked render.md.CheckboxComponent
---@field public checked render.md.CheckboxComponent
---@field public custom table<string, render.md.CustomCheckbox>

---@class (exact) render.md.Bullet: render.md.BaseComponent
---@field public icons render.md.bullet.Icons
---@field public ordered_icons render.md.bullet.Icons
---@field public left_pad render.md.bullet.Padding
---@field public right_pad render.md.bullet.Padding
---@field public highlight string

---@class (exact) render.md.Dash: render.md.BaseComponent
---@field public icon string
---@field public width 'full'|number
---@field public left_margin number
---@field public highlight string

---@class (exact) render.md.Code: render.md.BaseComponent
---@field public sign boolean
---@field public style render.md.code.Style
---@field public position render.md.code.Position
---@field public language_pad number
---@field public language_name boolean
---@field public disable_background boolean|string[]
---@field public width render.md.code.Width
---@field public left_margin number
---@field public left_pad number
---@field public right_pad number
---@field public min_width integer
---@field public border render.md.code.Border
---@field public above string
---@field public below string
---@field public highlight string
---@field public highlight_language? string
---@field public inline_pad integer
---@field public highlight_inline string

---@class (exact) render.md.Paragraph: render.md.BaseComponent
---@field public left_margin number
---@field public min_width integer

---@class (exact) render.md.Heading: render.md.BaseComponent
---@field public sign boolean
---@field public icons render.md.heading.Icons
---@field public position render.md.heading.Position
---@field public signs string[]
---@field public width render.md.heading.Width|(render.md.heading.Width)[]
---@field public left_margin number|number[]
---@field public left_pad number|number[]
---@field public right_pad number|number[]
---@field public min_width integer|integer[]
---@field public border boolean|boolean[]
---@field public border_virtual boolean
---@field public border_prefix boolean
---@field public above string
---@field public below string
---@field public backgrounds string[]
---@field public foregrounds string[]
---@field public custom table<string, render.md.HeadingCustom>

---@class (exact) render.md.Padding
---@field public highlight string

---@class (exact) render.md.AntiConceal
---@field public enabled boolean
---@field public ignore render.md.config.conceal.Ignore
---@field public above integer
---@field public below integer

---@class (exact) render.md.ConfigOverrides
---@field public buflisted table<boolean, render.md.UserBufferConfig>
---@field public buftype table<string, render.md.UserBufferConfig>
---@field public filetype table<string, render.md.UserBufferConfig>

---@class (exact) render.md.BufferConfig
---@field public enabled boolean
---@field public render_modes render.md.Modes
---@field public max_file_size number
---@field public debounce integer
---@field public anti_conceal render.md.AntiConceal
---@field public padding render.md.Padding
---@field public heading render.md.Heading
---@field public paragraph render.md.Paragraph
---@field public code render.md.Code
---@field public dash render.md.Dash
---@field public bullet render.md.Bullet
---@field public checkbox render.md.Checkbox
---@field public quote render.md.Quote
---@field public pipe_table render.md.PipeTable
---@field public callout table<string, render.md.CustomCallout>
---@field public link render.md.Link
---@field public sign render.md.Sign
---@field public inline_highlight render.md.InlineHighlight
---@field public indent render.md.Indent
---@field public latex render.md.Latex
---@field public html render.md.Html
---@field public win_options table<string, render.md.WindowOption>

---@class (exact) render.md.Config: render.md.BufferConfig
---@field public preset render.md.config.Preset
---@field public log_level render.md.config.LogLevel
---@field public log_runtime boolean
---@field public file_types string[]
---@field public change_events string[]
---@field public injections table<string, render.md.Injection>
---@field public on render.md.Callback
---@field public overrides render.md.ConfigOverrides
---@field public custom_handlers table<string, render.md.Handler>
