---@meta

---@class (exact) render.md.UserConfig: render.md.partial.UserConfig
---@field preset? render.md.config.Preset
---@field log_level? render.md.log.Level
---@field log_runtime? boolean
---@field file_types? string[]
---@field ignore? fun(buf: integer): boolean
---@field change_events? string[]
---@field injections? render.md.injection.UserConfigs
---@field patterns? render.md.pattern.UserConfigs
---@field on? render.md.on.UserConfig
---@field completions? render.md.completions.UserConfig
---@field overrides? render.md.overrides.UserConfig
---@field custom_handlers? table<string, render.md.Handler>

---@class (exact) render.md.partial.UserConfig: render.md.base.UserConfig
---@field max_file_size? number
---@field debounce? integer
---@field anti_conceal? render.md.anti.conceal.UserConfig
---@field bullet? render.md.bullet.UserConfig
---@field callout? render.md.callout.UserConfigs
---@field checkbox? render.md.checkbox.UserConfig
---@field code? render.md.code.UserConfig
---@field dash? render.md.dash.UserConfig
---@field document? render.md.document.UserConfig
---@field heading? render.md.heading.UserConfig
---@field html? render.md.html.UserConfig
---@field indent? render.md.indent.UserConfig
---@field inline_highlight? render.md.inline.highlight.UserConfig
---@field latex? render.md.latex.UserConfig
---@field link? render.md.link.UserConfig
---@field padding? render.md.padding.UserConfig
---@field paragraph? render.md.paragraph.UserConfig
---@field pipe_table? render.md.table.UserConfig
---@field quote? render.md.quote.UserConfig
---@field sign? render.md.sign.UserConfig
---@field win_options? render.md.window.UserConfigs

---@class (exact) render.md.anti.conceal.UserConfig
---@field enabled? boolean
---@field disabled_modes? render.md.Modes
---@field above? integer
---@field below? integer
---@field ignore? render.md.conceal.Ignore

---@class (exact) render.md.base.UserConfig
---@field enabled? boolean
---@field render_modes? render.md.Modes

---@class (exact) render.md.bullet.UserConfig: render.md.base.UserConfig
---@field icons? render.md.bullet.String
---@field ordered_icons? render.md.bullet.String
---@field left_pad? render.md.bullet.Integer
---@field right_pad? render.md.bullet.Integer
---@field highlight? render.md.bullet.String
---@field scope_highlight? render.md.bullet.String

---@alias render.md.callout.UserConfigs table<string, render.md.callout.UserConfig>

---@class (exact) render.md.callout.UserConfig
---@field raw? string
---@field rendered? string
---@field highlight? string
---@field quote_icon? string
---@field category? string

---@class (exact) render.md.checkbox.UserConfig: render.md.base.UserConfig
---@field bullet? boolean
---@field right_pad? integer
---@field unchecked? render.md.checkbox.component.UserConfig
---@field checked? render.md.checkbox.component.UserConfig
---@field custom? table<string, render.md.checkbox.custom.UserConfig>

---@class (exact) render.md.checkbox.component.UserConfig
---@field icon? string
---@field highlight? string
---@field scope_highlight? string

---@class (exact) render.md.checkbox.custom.UserConfig
---@field raw? string
---@field rendered? string
---@field highlight? string
---@field scope_highlight? string

---@class (exact) render.md.code.UserConfig: render.md.base.UserConfig
---@field sign? boolean
---@field style? render.md.code.Style
---@field position? render.md.code.Position
---@field language_pad? number
---@field language_icon? boolean
---@field language_name? boolean
---@field language_info? boolean
---@field disable_background? boolean|string[]
---@field width? render.md.code.Width
---@field left_margin? number
---@field left_pad? number
---@field right_pad? number
---@field min_width? integer
---@field border? render.md.code.Border
---@field language_border? string
---@field language_left? string
---@field language_right? string
---@field above? string
---@field below? string
---@field inline_left? string
---@field inline_right? string
---@field inline_pad? integer
---@field highlight? string
---@field highlight_info? string
---@field highlight_language? string
---@field highlight_border? false|string
---@field highlight_fallback? string
---@field highlight_inline? string

---@class (exact) render.md.completions.UserConfig
---@field blink? render.md.completion.UserConfig
---@field coq? render.md.completion.UserConfig
---@field lsp? render.md.completion.UserConfig
---@field filter? render.md.completion.filter.UserConfig

---@class (exact) render.md.completion.UserConfig
---@field enabled? boolean

---@class (exact) render.md.completion.filter.UserConfig
---@field callout? fun(value: render.md.callout.UserConfig): boolean
---@field checkbox? fun(value: render.md.checkbox.custom.UserConfig): boolean

---@class (exact) render.md.dash.UserConfig: render.md.base.UserConfig
---@field icon? string
---@field width? render.md.dash.Width
---@field left_margin? number
---@field highlight? string

---@class (exact) render.md.document.UserConfig: render.md.base.UserConfig
---@field conceal? render.md.document.conceal.UserConfig

---@class (exact) render.md.document.conceal.UserConfig
---@field char_patterns? string[]
---@field line_patterns? string[]

---@class (exact) render.md.heading.UserConfig: render.md.base.UserConfig
---@field atx? boolean
---@field setext? boolean
---@field sign? boolean
---@field icons? render.md.heading.String
---@field position? render.md.heading.Position
---@field signs? string[]
---@field width? render.md.heading.Width|(render.md.heading.Width)[]
---@field left_margin? number|number[]
---@field left_pad? number|number[]
---@field right_pad? number|number[]
---@field min_width? integer|integer[]
---@field border? boolean|boolean[]
---@field border_virtual? boolean
---@field border_prefix? boolean
---@field above? string
---@field below? string
---@field backgrounds? string[]
---@field foregrounds? string[]
---@field custom? table<string, render.md.heading.Custom>

---@class (exact) render.md.html.UserConfig: render.md.base.UserConfig
---@field comment? render.md.html.comment.UserConfig
---@field tag? table<string, render.md.html.Tag>

---@class (exact) render.md.html.comment.UserConfig
---@field conceal? boolean
---@field text? string
---@field highlight? string

---@class (exact) render.md.indent.UserConfig: render.md.base.UserConfig
---@field per_level? integer
---@field skip_level? integer
---@field skip_heading? boolean
---@field icon? string
---@field highlight? string

---@alias render.md.injection.UserConfigs table<string, render.md.injection.UserConfig>

---@class (exact) render.md.injection.UserConfig
---@field enabled? boolean
---@field query? string

---@class (exact) render.md.inline.highlight.UserConfig: render.md.base.UserConfig
---@field highlight? string

---@class (exact) render.md.latex.UserConfig: render.md.base.UserConfig
---@field converter? string
---@field highlight? string
---@field position? render.md.latex.Position
---@field top_pad? integer
---@field bottom_pad? integer

---@class (exact) render.md.link.UserConfig: render.md.base.UserConfig
---@field footnote? render.md.link.footnote.UserConfig
---@field image? string
---@field email? string
---@field hyperlink? string
---@field highlight? string
---@field wiki? render.md.link.wiki.UserConfig
---@field custom? table<string, render.md.link.custom.UserConfig>

---@class (exact) render.md.link.footnote.UserConfig
---@field enabled? boolean
---@field superscript? boolean
---@field prefix? string
---@field suffix? string

---@class (exact) render.md.link.wiki.UserConfig
---@field icon? string
---@field body? fun(ctx: render.md.link.Context): render.md.mark.Text|string?
---@field highlight? string

---@class (exact) render.md.link.custom.UserConfig
---@field pattern? string
---@field icon? string
---@field kind? render.md.link.custom.Kind
---@field priority? integer
---@field highlight? string

---@class (exact) render.md.on.UserConfig
---@field attach? fun(ctx: render.md.on.attach.Context)
---@field initial? fun(ctx: render.md.on.render.Context)
---@field render? fun(ctx: render.md.on.render.Context)
---@field clear? fun(ctx: render.md.on.render.Context)

---@class (exact) render.md.overrides.UserConfig
---@field buflisted? table<boolean, render.md.partial.UserConfig>
---@field buftype? table<string, render.md.partial.UserConfig>
---@field filetype? table<string, render.md.partial.UserConfig>

---@class (exact) render.md.padding.UserConfig
---@field highlight? string

---@class (exact) render.md.paragraph.UserConfig: render.md.base.UserConfig
---@field left_margin? render.md.paragraph.Number
---@field indent? render.md.paragraph.Number
---@field min_width? integer

---@alias render.md.pattern.UserConfigs table<string, render.md.pattern.UserConfig>

---@class (exact) render.md.pattern.UserConfig
---@field disable? boolean
---@field directives? render.md.directive.UserConfig[]

---@class (exact) render.md.directive.UserConfig
---@field id? integer
---@field name? string

---@class (exact) render.md.table.UserConfig: render.md.base.UserConfig
---@field preset? render.md.table.Preset
---@field style? render.md.table.Style
---@field cell? render.md.table.Cell
---@field padding? integer
---@field min_width? integer
---@field border? string[]
---@field border_virtual? boolean
---@field alignment_indicator? string
---@field head? string
---@field row? string
---@field filler? string

---@class (exact) render.md.quote.UserConfig: render.md.base.UserConfig
---@field icon? string|string[]
---@field repeat_linebreak? boolean
---@field highlight? string|string[]

---@class (exact) render.md.sign.UserConfig
---@field enabled? boolean
---@field highlight? string

---@alias render.md.window.UserConfigs table<string, render.md.window.UserConfig>

---@class (exact) render.md.window.UserConfig
---@field default? render.md.option.Value
---@field rendered? render.md.option.Value
