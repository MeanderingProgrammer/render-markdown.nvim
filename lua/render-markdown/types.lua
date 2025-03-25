---@meta

---@class (exact) render.md.CompletionFilter
---@field callout fun(value: render.md.CustomCallout): boolean
---@field checkbox fun(value: render.md.CustomCheckbox): boolean

---@class (exact) render.md.Completion
---@field enabled boolean

---@class (exact) render.md.Completions
---@field blink render.md.Completion
---@field coq render.md.Completion
---@field lsp render.md.Completion
---@field filter render.md.CompletionFilter

---@class (exact) render.md.Callback
---@field attach fun(ctx: render.md.CallbackContext)
---@field render fun(ctx: render.md.CallbackContext)
---@field clear fun(ctx: render.md.CallbackContext)

---@class (exact) render.md.Injection
---@field enabled boolean
---@field query string

---@class (exact) render.md.WindowOption
---@field default render.md.option.Value
---@field rendered render.md.option.Value

---@class (exact) render.md.BaseComponent
---@field enabled boolean
---@field render_modes render.md.Modes

---@class (exact) render.md.HtmlComment
---@field conceal boolean
---@field text? string
---@field highlight string

---@class (exact) render.md.Html: render.md.BaseComponent
---@field comment render.md.HtmlComment
---@field tag table<string, render.md.HtmlTag>

---@class (exact) render.md.Latex: render.md.BaseComponent
---@field converter string
---@field highlight string
---@field position render.md.latex.Position
---@field top_pad integer
---@field bottom_pad integer

---@class (exact) render.md.Indent: render.md.BaseComponent
---@field per_level integer
---@field skip_level integer
---@field skip_heading boolean
---@field icon string
---@field highlight string

---@class (exact) render.md.InlineHighlight: render.md.BaseComponent
---@field highlight string

---@class (exact) render.md.Sign
---@field enabled boolean
---@field highlight string

---@class (exact) render.md.LinkComponent
---@field pattern string
---@field icon string
---@field highlight? string

---@class (exact) render.md.WikiLink
---@field icon string
---@field body fun(ctx: render.md.LinkContext): render.md.MarkText|string?
---@field highlight string

---@class (exact) render.md.Footnote
---@field enabled boolean
---@field superscript boolean
---@field prefix string
---@field suffix string

---@class (exact) render.md.Link: render.md.BaseComponent
---@field footnote render.md.Footnote
---@field image string
---@field email string
---@field hyperlink string
---@field highlight string
---@field wiki render.md.WikiLink
---@field custom table<string, render.md.LinkComponent>

---@class (exact) render.md.CustomCallout
---@field raw string
---@field rendered string
---@field highlight string
---@field quote_icon? string
---@field category? string

---@class (exact) render.md.PipeTable: render.md.BaseComponent
---@field preset render.md.table.Preset
---@field style render.md.table.Style
---@field cell render.md.table.Cell
---@field padding integer
---@field min_width integer
---@field border string[]
---@field alignment_indicator string
---@field head string
---@field row string
---@field filler string

---@class (exact) render.md.Quote: render.md.BaseComponent
---@field icon string
---@field repeat_linebreak boolean
---@field highlight string

---@class (exact) render.md.CustomCheckbox
---@field raw string
---@field rendered string
---@field highlight string
---@field scope_highlight? string

---@class (exact) render.md.CheckboxComponent
---@field icon string
---@field highlight string
---@field scope_highlight? string

---@class (exact) render.md.Checkbox: render.md.BaseComponent
---@field right_pad integer
---@field unchecked render.md.CheckboxComponent
---@field checked render.md.CheckboxComponent
---@field custom table<string, render.md.CustomCheckbox>

---@class (exact) render.md.Bullet: render.md.BaseComponent
---@field icons render.md.bullet.Text
---@field ordered_icons render.md.bullet.Text
---@field left_pad render.md.bullet.Int
---@field right_pad render.md.bullet.Int
---@field highlight render.md.bullet.Text
---@field scope_highlight render.md.bullet.Text

---@class (exact) render.md.Dash: render.md.BaseComponent
---@field icon string
---@field width 'full'|number
---@field left_margin number
---@field highlight string

---@class (exact) render.md.Code: render.md.BaseComponent
---@field sign boolean
---@field style render.md.code.Style
---@field position render.md.code.Position
---@field language_pad number
---@field language_icon boolean
---@field language_name boolean
---@field disable_background boolean|string[]
---@field width render.md.code.Width
---@field left_margin number
---@field left_pad number
---@field right_pad number
---@field min_width integer
---@field border render.md.code.Border
---@field above string
---@field below string
---@field highlight string
---@field highlight_language? string
---@field highlight_fallback string
---@field inline_pad integer
---@field highlight_inline string

---@class (exact) render.md.Paragraph: render.md.BaseComponent
---@field left_margin number
---@field min_width integer

---@class (exact) render.md.Heading: render.md.BaseComponent
---@field sign boolean
---@field icons render.md.heading.Icons
---@field position render.md.heading.Position
---@field signs string[]
---@field width render.md.heading.Width|(render.md.heading.Width)[]
---@field left_margin number|number[]
---@field left_pad number|number[]
---@field right_pad number|number[]
---@field min_width integer|integer[]
---@field border boolean|boolean[]
---@field border_virtual boolean
---@field border_prefix boolean
---@field above string
---@field below string
---@field backgrounds string[]
---@field foregrounds string[]
---@field custom table<string, render.md.HeadingCustom>

---@class (exact) render.md.Padding
---@field highlight string

---@class (exact) render.md.AntiConceal
---@field enabled boolean
---@field ignore render.md.config.conceal.Ignore
---@field above integer
---@field below integer

---@class (exact) render.md.ConfigOverrides
---@field buflisted table<boolean, render.md.UserBufferConfig>
---@field buftype table<string, render.md.UserBufferConfig>
---@field filetype table<string, render.md.UserBufferConfig>

---@class (exact) render.md.BufferConfig
---@field enabled boolean
---@field render_modes render.md.Modes
---@field max_file_size number
---@field debounce integer
---@field anti_conceal render.md.AntiConceal
---@field padding render.md.Padding
---@field heading render.md.Heading
---@field paragraph render.md.Paragraph
---@field code render.md.Code
---@field dash render.md.Dash
---@field bullet render.md.Bullet
---@field checkbox render.md.Checkbox
---@field quote render.md.Quote
---@field pipe_table render.md.PipeTable
---@field callout table<string, render.md.CustomCallout>
---@field link render.md.Link
---@field sign render.md.Sign
---@field inline_highlight render.md.InlineHighlight
---@field indent render.md.Indent
---@field latex render.md.Latex
---@field html render.md.Html
---@field win_options table<string, render.md.WindowOption>

---@class (exact) render.md.Config: render.md.BufferConfig
---@field preset render.md.config.Preset
---@field log_level render.md.config.LogLevel
---@field log_runtime boolean
---@field file_types string[]
---@field change_events string[]
---@field injections table<string, render.md.Injection>
---@field on render.md.Callback
---@field completions render.md.Completions
---@field overrides render.md.ConfigOverrides
---@field custom_handlers table<string, render.md.Handler>
