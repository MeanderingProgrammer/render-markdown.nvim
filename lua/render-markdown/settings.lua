---@class render.md.Settings
local M = {}

---@class render.md.anti.conceal.Settings
M.anti_conceal = {}

---@class (exact) render.md.anti.conceal.Config
---@field enabled boolean
---@field disabled_modes render.md.Modes
---@field above integer
---@field below integer
---@field ignore render.md.conceal.Ignore

---@alias render.md.conceal.Ignore table<render.md.Element, render.md.Modes>

---@enum render.md.Element
M.anti_conceal.element = {
    bullet = 'bullet',
    callout = 'callout',
    check_icon = 'check_icon',
    check_scope = 'check_scope',
    code_background = 'code_background',
    code_border = 'code_border',
    code_language = 'code_language',
    dash = 'dash',
    head_background = 'head_background',
    head_border = 'head_border',
    head_icon = 'head_icon',
    indent = 'indent',
    latex = 'latex',
    link = 'link',
    quote = 'quote',
    sign = 'sign',
    table_border = 'table_border',
    virtual_lines = 'virtual_lines',
}

---@type render.md.anti.conceal.Config
M.anti_conceal.default = {
    -- This enables hiding added text on the line the cursor is on.
    enabled = true,
    -- Modes to disable anti conceal feature.
    disabled_modes = false,
    -- Number of lines above cursor to show.
    above = 0,
    -- Number of lines below cursor to show.
    below = 0,
    -- Which elements to always show, ignoring anti conceal behavior. Values can either be
    -- booleans to fix the behavior or string lists representing modes where anti conceal
    -- behavior will be ignored. Valid values are:
    --   bullet
    --   callout
    --   check_icon, check_scope
    --   code_background, code_border, code_language
    --   dash
    --   head_background, head_border, head_icon
    --   indent
    --   latex
    --   link
    --   quote
    --   sign
    --   table_border
    --   virtual_lines
    ignore = {
        code_background = true,
        indent = true,
        sign = true,
        virtual_lines = true,
    },
}

---@return render.md.Schema
function M.anti_conceal.schema()
    ---@type render.md.Schema
    local modes = {
        union = { { list = { type = 'string' } }, { type = 'boolean' } },
    }
    ---@type render.md.Schema
    return {
        record = {
            enabled = { type = 'boolean' },
            disabled_modes = modes,
            above = { type = 'number' },
            below = { type = 'number' },
            ignore = { map = { { enum = M.anti_conceal.element }, modes } },
        },
    }
end

---@class render.md.base.Settings
M.base = {}

---@class (exact) render.md.base.Config
---@field enabled boolean
---@field render_modes render.md.Modes

---@alias render.md.Modes boolean|string[]

---@param child render.md.schema.Record
---@return render.md.Schema
function M.base.schema(child)
    ---@type render.md.schema.Record
    local parent = {
        enabled = { type = 'boolean' },
        render_modes = {
            union = { { list = { type = 'string' } }, { type = 'boolean' } },
        },
    }
    ---@type render.md.Schema
    return { record = vim.tbl_deep_extend('error', parent, child) }
end

---@class render.md.bullet.Settings
M.bullet = {}

---@class (exact) render.md.bullet.Config: render.md.base.Config
---@field icons render.md.bullet.String
---@field ordered_icons render.md.bullet.String
---@field left_pad render.md.bullet.Integer
---@field right_pad render.md.bullet.Integer
---@field highlight render.md.bullet.String
---@field scope_highlight render.md.bullet.String
---@field scope_priority? integer

---@class (exact) render.md.bullet.Context
---@field level integer
---@field index integer
---@field value string

---@alias render.md.bullet.String
---| string
---| string[]
---| string[][]
---| fun(ctx: render.md.bullet.Context): string?

---@alias render.md.bullet.Integer
---| integer
---| fun(ctx: render.md.bullet.Context): integer

---@type render.md.bullet.Config
M.bullet.default = {
    -- Useful context to have when evaluating values.
    -- | level | how deeply nested the list is, 1-indexed          |
    -- | index | how far down the item is at that level, 1-indexed |
    -- | value | text value of the marker node                     |

    -- Turn on / off list bullet rendering
    enabled = true,
    -- Additional modes to render list bullets
    render_modes = false,
    -- Replaces '-'|'+'|'*' of 'list_item'.
    -- If the item is a 'checkbox' a conceal is used to hide the bullet instead.
    -- Output is evaluated depending on the type.
    -- | function   | `value(context)`                                    |
    -- | string     | `value`                                             |
    -- | string[]   | `cycle(value, context.level)`                       |
    -- | string[][] | `clamp(cycle(value, context.level), context.index)` |
    icons = { '●', '○', '◆', '◇' },
    -- Replaces 'n.'|'n)' of 'list_item'.
    -- Output is evaluated using the same logic as 'icons'.
    ordered_icons = function(ctx)
        local value = vim.trim(ctx.value)
        local index = tonumber(value:sub(1, #value - 1))
        return ('%d.'):format(index > 1 and index or ctx.index)
    end,
    -- Padding to add to the left of bullet point.
    -- Output is evaluated depending on the type.
    -- | function | `value(context)` |
    -- | integer  | `value`          |
    left_pad = 0,
    -- Padding to add to the right of bullet point.
    -- Output is evaluated using the same logic as 'left_pad'.
    right_pad = 0,
    -- Highlight for the bullet icon.
    -- Output is evaluated using the same logic as 'icons'.
    highlight = 'RenderMarkdownBullet',
    -- Highlight for item associated with the bullet point.
    -- Output is evaluated using the same logic as 'icons'.
    scope_highlight = {},
    -- Priority to assign to scope highlight.
    scope_priority = nil,
}

---@return render.md.Schema
function M.bullet.schema()
    ---@type render.md.Schema
    local string_provider = {
        union = {
            { type = 'string' },
            { list = { type = 'string' } },
            { list = { list = { type = 'string' } } },
            { type = 'function' },
        },
    }
    ---@type render.md.Schema
    local integer_provider = {
        union = { { type = 'number' }, { type = 'function' } },
    }
    return M.base.schema({
        icons = string_provider,
        ordered_icons = string_provider,
        left_pad = integer_provider,
        right_pad = integer_provider,
        highlight = string_provider,
        scope_highlight = string_provider,
        scope_priority = { optional = true, type = 'number' },
    })
end

---@class (exact) render.md.raw.Config
---@field raw string

---@class render.md.callout.Settings
M.callout = {}

---@alias render.md.callout.Configs table<string, render.md.callout.Config>

---@class (exact) render.md.callout.Config: render.md.raw.Config
---@field rendered string
---@field highlight string
---@field quote_icon? string
---@field category? string

-- stylua: ignore
---@type render.md.callout.Configs
M.callout.default = {
    -- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'.
    -- The key is for healthcheck and to allow users to change its values, value type below.
    -- | raw        | matched against the raw text of a 'shortcut_link', case insensitive |
    -- | rendered   | replaces the 'raw' value when rendering                             |
    -- | highlight  | highlight for the 'rendered' text and quote markers                 |
    -- | quote_icon | optional override for quote.icon value for individual callout       |
    -- | category   | optional metadata useful for filtering                              |

    note      = { raw = '[!NOTE]',      rendered = '󰋽 Note',      highlight = 'RenderMarkdownInfo',    category = 'github'   },
    tip       = { raw = '[!TIP]',       rendered = '󰌶 Tip',       highlight = 'RenderMarkdownSuccess', category = 'github'   },
    important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint',    category = 'github'   },
    warning   = { raw = '[!WARNING]',   rendered = '󰀪 Warning',   highlight = 'RenderMarkdownWarn',    category = 'github'   },
    caution   = { raw = '[!CAUTION]',   rendered = '󰳦 Caution',   highlight = 'RenderMarkdownError',   category = 'github'   },
    -- Obsidian: https://help.obsidian.md/Editing+and+formatting/Callouts
    abstract  = { raw = '[!ABSTRACT]',  rendered = '󰨸 Abstract',  highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
    summary   = { raw = '[!SUMMARY]',   rendered = '󰨸 Summary',   highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
    tldr      = { raw = '[!TLDR]',      rendered = '󰨸 Tldr',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
    info      = { raw = '[!INFO]',      rendered = '󰋽 Info',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
    todo      = { raw = '[!TODO]',      rendered = '󰗡 Todo',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
    hint      = { raw = '[!HINT]',      rendered = '󰌶 Hint',      highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
    success   = { raw = '[!SUCCESS]',   rendered = '󰄬 Success',   highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
    check     = { raw = '[!CHECK]',     rendered = '󰄬 Check',     highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
    done      = { raw = '[!DONE]',      rendered = '󰄬 Done',      highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
    question  = { raw = '[!QUESTION]',  rendered = '󰘥 Question',  highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
    help      = { raw = '[!HELP]',      rendered = '󰘥 Help',      highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
    faq       = { raw = '[!FAQ]',       rendered = '󰘥 Faq',       highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
    attention = { raw = '[!ATTENTION]', rendered = '󰀪 Attention', highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
    failure   = { raw = '[!FAILURE]',   rendered = '󰅖 Failure',   highlight = 'RenderMarkdownError',   category = 'obsidian' },
    fail      = { raw = '[!FAIL]',      rendered = '󰅖 Fail',      highlight = 'RenderMarkdownError',   category = 'obsidian' },
    missing   = { raw = '[!MISSING]',   rendered = '󰅖 Missing',   highlight = 'RenderMarkdownError',   category = 'obsidian' },
    danger    = { raw = '[!DANGER]',    rendered = '󱐌 Danger',    highlight = 'RenderMarkdownError',   category = 'obsidian' },
    error     = { raw = '[!ERROR]',     rendered = '󱐌 Error',     highlight = 'RenderMarkdownError',   category = 'obsidian' },
    bug       = { raw = '[!BUG]',       rendered = '󰨰 Bug',       highlight = 'RenderMarkdownError',   category = 'obsidian' },
    example   = { raw = '[!EXAMPLE]',   rendered = '󰉹 Example',   highlight = 'RenderMarkdownHint' ,   category = 'obsidian' },
    quote     = { raw = '[!QUOTE]',     rendered = '󱆨 Quote',     highlight = 'RenderMarkdownQuote',   category = 'obsidian' },
    cite      = { raw = '[!CITE]',      rendered = '󱆨 Cite',      highlight = 'RenderMarkdownQuote',   category = 'obsidian' },
}

---@return render.md.Schema
function M.callout.schema()
    ---@type render.md.Schema
    local callout = {
        record = {
            raw = { type = 'string' },
            rendered = { type = 'string' },
            highlight = { type = 'string' },
            quote_icon = { optional = true, type = 'string' },
            category = { optional = true, type = 'string' },
        },
    }
    ---@type render.md.Schema
    return { map = { { type = 'string' }, callout } }
end

---@class render.md.checkbox.Settings
M.checkbox = {}

---@class (exact) render.md.checkbox.Config: render.md.base.Config
---@field bullet boolean
---@field left_pad number
---@field right_pad integer
---@field unchecked render.md.checkbox.component.Config
---@field checked render.md.checkbox.component.Config
---@field custom table<string, render.md.checkbox.custom.Config>
---@field scope_priority? integer

---@class (exact) render.md.checkbox.component.Config
---@field icon string
---@field highlight string
---@field scope_highlight? string

---@class (exact) render.md.checkbox.custom.Config: render.md.raw.Config
---@field rendered string
---@field highlight string
---@field scope_highlight? string

---@type render.md.checkbox.Config
M.checkbox.default = {
    -- Checkboxes are a special instance of a 'list_item' that start with a 'shortcut_link'.
    -- There are two special states for unchecked & checked defined in the markdown grammar.

    -- Turn on / off checkbox state rendering.
    enabled = true,
    -- Additional modes to render checkboxes.
    render_modes = false,
    -- Render the bullet point before the checkbox.
    bullet = false,
    -- Padding to add to the left of checkboxes.
    left_pad = 0,
    -- Padding to add to the right of checkboxes.
    right_pad = 1,
    unchecked = {
        -- Replaces '[ ]' of 'task_list_marker_unchecked'.
        icon = '󰄱 ',
        -- Highlight for the unchecked icon.
        highlight = 'RenderMarkdownUnchecked',
        -- Highlight for item associated with unchecked checkbox.
        scope_highlight = nil,
    },
    checked = {
        -- Replaces '[x]' of 'task_list_marker_checked'.
        icon = '󰱒 ',
        -- Highlight for the checked icon.
        highlight = 'RenderMarkdownChecked',
        -- Highlight for item associated with checked checkbox.
        scope_highlight = nil,
    },
    -- Define custom checkbox states, more involved, not part of the markdown grammar.
    -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks.
    -- The key is for healthcheck and to allow users to change its values, value type below.
    -- | raw             | matched against the raw text of a 'shortcut_link'           |
    -- | rendered        | replaces the 'raw' value when rendering                     |
    -- | highlight       | highlight for the 'rendered' icon                           |
    -- | scope_highlight | optional highlight for item associated with custom checkbox |
    -- stylua: ignore
    custom = {
        todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
    },
    -- Priority to assign to scope highlight.
    scope_priority = nil,
}

---@return render.md.Schema
function M.checkbox.schema()
    ---@type render.md.Schema
    local component = {
        record = {
            icon = { type = 'string' },
            highlight = { type = 'string' },
            scope_highlight = { optional = true, type = 'string' },
        },
    }
    ---@type render.md.Schema
    local custom = {
        record = {
            raw = { type = 'string' },
            rendered = { type = 'string' },
            highlight = { type = 'string' },
            scope_highlight = { optional = true, type = 'string' },
        },
    }
    return M.base.schema({
        bullet = { type = 'boolean' },
        left_pad = { type = 'number' },
        right_pad = { type = 'number' },
        unchecked = component,
        checked = component,
        custom = { map = { { type = 'string' }, custom } },
        scope_priority = { optional = true, type = 'number' },
    })
end

---@class render.md.code.Settings
M.code = {}

---@class (exact) render.md.code.Config: render.md.base.Config
---@field sign boolean
---@field conceal_delimiters boolean
---@field language boolean
---@field position render.md.code.Position
---@field language_icon boolean
---@field language_name boolean
---@field language_info boolean
---@field language_pad number
---@field disable_background boolean|string[]
---@field width render.md.code.Width
---@field left_margin number
---@field left_pad number
---@field right_pad number
---@field min_width integer
---@field border render.md.code.Border
---@field language_border string
---@field language_left string
---@field language_right string
---@field above string
---@field below string
---@field inline boolean
---@field inline_left string
---@field inline_right string
---@field inline_pad integer
---@field priority? integer
---@field highlight string
---@field highlight_info string
---@field highlight_language? string
---@field highlight_border false|string
---@field highlight_fallback string
---@field highlight_inline string
---@field style render.md.code.Style

---@enum render.md.code.Position
M.code.position = {
    left = 'left',
    right = 'right',
}

---@enum render.md.code.Width
M.code.width = {
    full = 'full',
    block = 'block',
}

---@enum render.md.code.Border
M.code.border = {
    hide = 'hide',
    thin = 'thin',
    thick = 'thick',
    none = 'none',
}

---@enum render.md.code.Style
M.code.style = {
    full = 'full',
    normal = 'normal',
    language = 'language',
    none = 'none',
}

---@type render.md.code.Config
M.code.default = {
    -- Turn on / off code block & inline code rendering.
    enabled = true,
    -- Additional modes to render code blocks.
    render_modes = false,
    -- Turn on / off sign column related rendering.
    sign = true,
    -- Whether to conceal nodes at the top and bottom of code blocks.
    conceal_delimiters = true,
    -- Turn on / off language heading related rendering.
    language = true,
    -- Determines where language icon is rendered.
    -- | right | right side of code block |
    -- | left  | left side of code block  |
    position = 'left',
    -- Whether to include the language icon above code blocks.
    language_icon = true,
    -- Whether to include the language name above code blocks.
    language_name = true,
    -- Whether to include the language info above code blocks.
    language_info = true,
    -- Amount of padding to add around the language.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    language_pad = 0,
    -- A list of language names for which background highlighting will be disabled.
    -- Likely because that language has background highlights itself.
    -- Use a boolean to make behavior apply to all languages.
    -- Borders above & below blocks will continue to be rendered.
    disable_background = { 'diff' },
    -- Width of the code block background.
    -- | block | width of the code block  |
    -- | full  | full width of the window |
    width = 'full',
    -- Amount of margin to add to the left of code blocks.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    -- Margin available space is computed after accounting for padding.
    left_margin = 0,
    -- Amount of padding to add to the left of code blocks.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    left_pad = 0,
    -- Amount of padding to add to the right of code blocks when width is 'block'.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    right_pad = 0,
    -- Minimum width to use for code blocks when width is 'block'.
    min_width = 0,
    -- Determines how the top / bottom of code block are rendered.
    -- | none  | do not render a border                               |
    -- | thick | use the same highlight as the code body              |
    -- | thin  | when lines are empty overlay the above & below icons |
    -- | hide  | conceal lines unless language name or icon is added  |
    border = 'hide',
    -- Used above code blocks to fill remaining space around language.
    language_border = '█',
    -- Added to the left of language.
    language_left = '',
    -- Added to the right of language.
    language_right = '',
    -- Used above code blocks for thin border.
    above = '▄',
    -- Used below code blocks for thin border.
    below = '▀',
    -- Turn on / off inline code related rendering.
    inline = true,
    -- Icon to add to the left of inline code.
    inline_left = '',
    -- Icon to add to the right of inline code.
    inline_right = '',
    -- Padding to add to the left & right of inline code.
    inline_pad = 0,
    -- Priority to assign to code background highlight.
    priority = nil,
    -- Highlight for code blocks.
    highlight = 'RenderMarkdownCode',
    -- Highlight for code info section, after the language.
    highlight_info = 'RenderMarkdownCodeInfo',
    -- Highlight for language, overrides icon provider value.
    highlight_language = nil,
    -- Highlight for border, use false to add no highlight.
    highlight_border = 'RenderMarkdownCodeBorder',
    -- Highlight for language, used if icon provider does not have a value.
    highlight_fallback = 'RenderMarkdownCodeFallback',
    -- Highlight for inline code.
    highlight_inline = 'RenderMarkdownCodeInline',
    -- Determines how code blocks & inline code are rendered.
    -- | none     | { enabled = false }                           |
    -- | normal   | { language = false }                          |
    -- | language | { disable_background = true, inline = false } |
    -- | full     | uses all default values                       |
    style = 'full',
}

---@return render.md.Schema
function M.code.schema()
    return M.base.schema({
        sign = { type = 'boolean' },
        conceal_delimiters = { type = 'boolean' },
        language = { type = 'boolean' },
        position = { enum = M.code.position },
        language_icon = { type = 'boolean' },
        language_name = { type = 'boolean' },
        language_info = { type = 'boolean' },
        language_pad = { type = 'number' },
        disable_background = {
            union = { { list = { type = 'string' } }, { type = 'boolean' } },
        },
        width = { enum = M.code.width },
        left_margin = { type = 'number' },
        left_pad = { type = 'number' },
        right_pad = { type = 'number' },
        min_width = { type = 'number' },
        border = { enum = M.code.border },
        language_border = { type = 'string' },
        language_left = { type = 'string' },
        language_right = { type = 'string' },
        above = { type = 'string' },
        below = { type = 'string' },
        inline = { type = 'boolean' },
        inline_left = { type = 'string' },
        inline_right = { type = 'string' },
        inline_pad = { type = 'number' },
        priority = { optional = true, type = 'number' },
        highlight = { type = 'string' },
        highlight_info = { type = 'string' },
        highlight_language = { optional = true, type = 'string' },
        highlight_border = {
            union = { { enum = { false } }, { type = 'string' } },
        },
        highlight_fallback = { type = 'string' },
        highlight_inline = { type = 'string' },
        style = { enum = M.code.style },
    })
end

---@class render.md.completions.Settings
M.completions = {}

---@class (exact) render.md.completions.Config
---@field blink render.md.completion.Config
---@field coq render.md.completion.Config
---@field lsp render.md.completion.Config
---@field filter render.md.completion.filter.Config

---@class (exact) render.md.completion.Config
---@field enabled boolean

---@class (exact) render.md.completion.filter.Config
---@field callout fun(value: render.md.callout.Config): boolean
---@field checkbox fun(value: render.md.checkbox.custom.Config): boolean

---@type render.md.completions.Config
M.completions.default = {
    -- Settings for blink.cmp completions source
    blink = { enabled = false },
    -- Settings for coq_nvim completions source
    coq = { enabled = false },
    -- Settings for in-process language server completions
    lsp = { enabled = false },
    filter = {
        callout = function()
            -- example to exclude obsidian callouts
            -- return value.category ~= 'obsidian'
            return true
        end,
        checkbox = function()
            return true
        end,
    },
}

---@return render.md.Schema
function M.completions.schema()
    ---@type render.md.Schema
    local completion = { record = { enabled = { type = 'boolean' } } }
    ---@type render.md.Schema
    return {
        record = {
            blink = completion,
            coq = completion,
            lsp = completion,
            filter = {
                record = {
                    callout = { type = 'function' },
                    checkbox = { type = 'function' },
                },
            },
        },
    }
end

---@class render.md.dash.Settings
M.dash = {}

---@class (exact) render.md.dash.Config: render.md.base.Config
---@field icon string
---@field width render.md.dash.Width
---@field left_margin number
---@field highlight string

---@class (exact) render.md.dash.Context
---@field width integer

---@alias render.md.dash.Width
---| 'full'
---| number
---| fun(ctx: render.md.dash.Context): integer

---@type render.md.dash.Config
M.dash.default = {
    -- Useful context to have when evaluating values.
    -- | width | width of the current window |

    -- Turn on / off thematic break rendering.
    enabled = true,
    -- Additional modes to render dash.
    render_modes = false,
    -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'.
    -- The icon gets repeated across the window's width.
    icon = '─',
    -- Width of the generated line.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    -- Output is evaluated depending on the type.
    -- | function | `value(context)`    |
    -- | number   | `value`             |
    -- | full     | width of the window |
    width = 'full',
    -- Amount of margin to add to the left of dash.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    left_margin = 0,
    -- Highlight for the whole line generated from the icon.
    highlight = 'RenderMarkdownDash',
}

---@return render.md.Schema
function M.dash.schema()
    return M.base.schema({
        icon = { type = 'string' },
        width = {
            union = {
                { enum = { 'full' } },
                { type = 'number' },
                { type = 'function' },
            },
        },
        left_margin = { type = 'number' },
        highlight = { type = 'string' },
    })
end

---@class render.md.document.Settings
M.document = {}

---@class (exact) render.md.document.Config: render.md.base.Config
---@field conceal render.md.document.conceal.Config

---@class (exact) render.md.document.conceal.Config
---@field char_patterns string[]
---@field line_patterns string[]

---@type render.md.document.Config
M.document.default = {
    -- Turn on / off document rendering.
    enabled = true,
    -- Additional modes to render document.
    render_modes = false,
    -- Ability to conceal arbitrary ranges of text based on lua patterns, @see :h lua-patterns.
    -- Relies entirely on user to set patterns that handle their edge cases.
    conceal = {
        -- Matched ranges will be concealed using character level conceal.
        char_patterns = {},
        -- Matched ranges will be concealed using line level conceal.
        line_patterns = {},
    },
}

---@return render.md.Schema
function M.document.schema()
    return M.base.schema({
        conceal = {
            record = {
                char_patterns = { list = { type = 'string' } },
                line_patterns = { list = { type = 'string' } },
            },
        },
    })
end

---@class render.md.handlers.Settings
M.handlers = {}

---@class (exact) render.md.Handler
---@field extends? boolean
---@field parse fun(ctx: render.md.handler.Context): render.md.Mark[]

---@class (exact) render.md.handler.Context
---@field buf integer
---@field root TSNode
---@field last boolean

---@type table<string, render.md.Handler>
M.handlers.default = {
    -- Mapping from treesitter language to user defined handlers.
    -- @see [Custom Handlers](doc/custom-handlers.md)
}

---@return render.md.Schema
function M.handlers.schema()
    ---@type render.md.Schema
    local handler = {
        record = {
            extends = { optional = true, type = 'boolean' },
            parse = { type = 'function' },
        },
    }
    ---@type render.md.Schema
    return { map = { { type = 'string' }, handler } }
end

---@class render.md.heading.Settings
M.heading = {}

---@class (exact) render.md.heading.Config: render.md.base.Config
---@field atx boolean
---@field setext boolean
---@field sign boolean
---@field icons render.md.heading.String
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
---@field custom table<string, render.md.heading.Custom>

---@class (exact) render.md.heading.Context
---@field level integer
---@field sections integer[]

---@alias render.md.heading.String
---| string[]
---| fun(ctx: render.md.heading.Context): string?

---@enum render.md.heading.Position
M.heading.position = {
    overlay = 'overlay',
    inline = 'inline',
    right = 'right',
}

---@enum render.md.heading.Width
M.heading.width = {
    full = 'full',
    block = 'block',
}

---@class (exact) render.md.heading.Custom
---@field pattern string
---@field icon? string
---@field background? string
---@field foreground? string

---@type render.md.heading.Config
M.heading.default = {
    -- Useful context to have when evaluating values.
    -- | level    | the number of '#' in the heading marker         |
    -- | sections | for each level how deeply nested the heading is |

    -- Turn on / off heading icon & background rendering.
    enabled = true,
    -- Additional modes to render headings.
    render_modes = false,
    -- Turn on / off atx heading rendering.
    atx = true,
    -- Turn on / off setext heading rendering.
    setext = true,
    -- Turn on / off sign column related rendering.
    sign = true,
    -- Replaces '#+' of 'atx_h._marker'.
    -- Output is evaluated depending on the type.
    -- | function | `value(context)`              |
    -- | string[] | `cycle(value, context.level)` |
    icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    -- Determines how icons fill the available space.
    -- | right   | '#'s are concealed and icon is appended to right side                      |
    -- | inline  | '#'s are concealed and icon is inlined on left side                        |
    -- | overlay | icon is left padded with spaces and inserted on left hiding additional '#' |
    position = 'overlay',
    -- Added to the sign column if enabled.
    -- Output is evaluated by `cycle(value, context.level)`.
    signs = { '󰫎 ' },
    -- Width of the heading background.
    -- | block | width of the heading text |
    -- | full  | full width of the window  |
    -- Can also be a list of the above values evaluated by `clamp(value, context.level)`.
    width = 'full',
    -- Amount of margin to add to the left of headings.
    -- Margin available space is computed after accounting for padding.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    -- Can also be a list of numbers evaluated by `clamp(value, context.level)`.
    left_margin = 0,
    -- Amount of padding to add to the left of headings.
    -- Output is evaluated using the same logic as 'left_margin'.
    left_pad = 0,
    -- Amount of padding to add to the right of headings when width is 'block'.
    -- Output is evaluated using the same logic as 'left_margin'.
    right_pad = 0,
    -- Minimum width to use for headings when width is 'block'.
    -- Can also be a list of integers evaluated by `clamp(value, context.level)`.
    min_width = 0,
    -- Determines if a border is added above and below headings.
    -- Can also be a list of booleans evaluated by `clamp(value, context.level)`.
    border = false,
    -- Always use virtual lines for heading borders instead of attempting to use empty lines.
    border_virtual = false,
    -- Highlight the start of the border using the foreground highlight.
    border_prefix = false,
    -- Used above heading for border.
    above = '▄',
    -- Used below heading for border.
    below = '▀',
    -- Highlight for the heading icon and extends through the entire line.
    -- Output is evaluated by `clamp(value, context.level)`.
    backgrounds = {
        'RenderMarkdownH1Bg',
        'RenderMarkdownH2Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH4Bg',
        'RenderMarkdownH5Bg',
        'RenderMarkdownH6Bg',
    },
    -- Highlight for the heading and sign icons.
    -- Output is evaluated using the same logic as 'backgrounds'.
    foregrounds = {
        'RenderMarkdownH1',
        'RenderMarkdownH2',
        'RenderMarkdownH3',
        'RenderMarkdownH4',
        'RenderMarkdownH5',
        'RenderMarkdownH6',
    },
    -- Define custom heading patterns which allow you to override various properties based on
    -- the contents of a heading.
    -- The key is for healthcheck and to allow users to change its values, value type below.
    -- | pattern    | matched against the heading text @see :h lua-patterns |
    -- | icon       | optional override for the icon                        |
    -- | background | optional override for the background                  |
    -- | foreground | optional override for the foreground                  |
    custom = {},
}

---@return render.md.Schema
function M.heading.schema()
    ---@type render.md.Schema
    local width = { enum = M.heading.width }
    ---@type render.md.Schema
    local custom = {
        record = {
            pattern = { type = 'string' },
            icon = { optional = true, type = 'string' },
            background = { optional = true, type = 'string' },
            foreground = { optional = true, type = 'string' },
        },
    }
    return M.base.schema({
        atx = { type = 'boolean' },
        setext = { type = 'boolean' },
        sign = { type = 'boolean' },
        icons = {
            union = { { list = { type = 'string' } }, { type = 'function' } },
        },
        position = { enum = M.heading.position },
        signs = { list = { type = 'string' } },
        width = {
            union = { { list = width }, width },
        },
        left_margin = {
            union = { { list = { type = 'number' } }, { type = 'number' } },
        },
        left_pad = {
            union = { { list = { type = 'number' } }, { type = 'number' } },
        },
        right_pad = {
            union = { { list = { type = 'number' } }, { type = 'number' } },
        },
        min_width = {
            union = { { list = { type = 'number' } }, { type = 'number' } },
        },
        border = {
            union = { { list = { type = 'boolean' } }, { type = 'boolean' } },
        },
        border_virtual = { type = 'boolean' },
        border_prefix = { type = 'boolean' },
        above = { type = 'string' },
        below = { type = 'string' },
        backgrounds = { list = { type = 'string' } },
        foregrounds = { list = { type = 'string' } },
        custom = { map = { { type = 'string' }, custom } },
    })
end

---@class render.md.html.Settings
M.html = {}

---@class (exact) render.md.html.Config: render.md.base.Config
---@field comment render.md.html.comment.Config
---@field tag table<string, render.md.html.Tag>

---@class (exact) render.md.html.comment.Config
---@field conceal boolean
---@field text? render.md.html.comment.String
---@field highlight string

---@class (exact) render.md.html.comment.Context
---@field text string

---@alias render.md.html.comment.String
---| string
---| fun(ctx: render.md.html.comment.Context): string?

---@class (exact) render.md.html.Tag
---@field icon? string
---@field highlight? string
---@field scope_highlight? string

---@type render.md.html.Config
M.html.default = {
    -- Turn on / off all HTML rendering.
    enabled = true,
    -- Additional modes to render HTML.
    render_modes = false,
    comment = {
        -- Useful context to have when evaluating values.
        -- | text | text value of the comment node |

        -- Turn on / off HTML comment concealing.
        conceal = true,
        -- Text to inline before the concealed comment.
        -- Output is evaluated depending on the type.
        -- | function | `value(context)` |
        -- | string   | `value`          |
        -- | nil      | nothing          |
        text = nil,
        -- Highlight for the inlined text.
        highlight = 'RenderMarkdownHtmlComment',
    },
    -- HTML tags whose start and end will be hidden and icon shown.
    -- The key is matched against the tag name, value type below.
    -- | icon            | optional icon inlined at start of tag           |
    -- | highlight       | optional highlight for the icon                 |
    -- | scope_highlight | optional highlight for item associated with tag |
    tag = {},
}

---@return render.md.Schema
function M.html.schema()
    ---@type render.md.Schema
    local tag = {
        record = {
            icon = { optional = true, type = 'string' },
            highlight = { optional = true, type = 'string' },
            scope_highlight = { optional = true, type = 'string' },
        },
    }
    return M.base.schema({
        comment = {
            record = {
                conceal = { type = 'boolean' },
                text = {
                    optional = true,
                    union = { { type = 'string' }, { type = 'function' } },
                },
                highlight = { type = 'string' },
            },
        },
        tag = { map = { { type = 'string' }, tag } },
    })
end

---@class render.md.indent.Settings
M.indent = {}

---@class (exact) render.md.indent.Config: render.md.base.Config
---@field per_level integer
---@field skip_level integer
---@field skip_heading boolean
---@field icon string
---@field priority integer
---@field highlight string

---@type render.md.indent.Config
M.indent.default = {
    -- Mimic org-indent-mode behavior by indenting everything under a heading based on the
    -- level of the heading. Indenting starts from level 2 headings onward by default.

    -- Turn on / off org-indent-mode.
    enabled = false,
    -- Additional modes to render indents.
    render_modes = false,
    -- Amount of additional padding added for each heading level.
    per_level = 2,
    -- Heading levels <= this value will not be indented.
    -- Use 0 to begin indenting from the very first level.
    skip_level = 1,
    -- Do not indent heading titles, only the body.
    skip_heading = false,
    -- Prefix added when indenting, one per level.
    icon = '▎',
    -- Priority to assign to extmarks.
    priority = 0,
    -- Applied to icon.
    highlight = 'RenderMarkdownIndent',
}

---@return render.md.Schema
function M.indent.schema()
    return M.base.schema({
        per_level = { type = 'number' },
        skip_level = { type = 'number' },
        skip_heading = { type = 'boolean' },
        icon = { type = 'string' },
        priority = { type = 'number' },
        highlight = { type = 'string' },
    })
end

---@class render.md.injections.Settings
M.injections = {}

---@alias render.md.injection.Configs table<string, render.md.injection.Config>

---@class (exact) render.md.injection.Config
---@field enabled boolean
---@field query string

---@type render.md.injection.Configs
M.injections.default = {
    -- Out of the box language injections for known filetypes that allow markdown to be interpreted
    -- in specified locations, see :h treesitter-language-injections.
    -- Set enabled to false in order to disable.

    gitcommit = {
        enabled = true,
        query = [[
            ((message) @injection.content
                (#set! injection.combined)
                (#set! injection.include-children)
                (#set! injection.language "markdown"))
        ]],
    },
}

---@return render.md.Schema
function M.injections.schema()
    ---@type render.md.Schema
    local injection = {
        record = {
            enabled = { type = 'boolean' },
            query = { type = 'string' },
        },
    }
    ---@type render.md.Schema
    return { map = { { type = 'string' }, injection } }
end

---@class render.md.inline.highlight.Settings
M.inline_highlight = {}

---@class (exact) render.md.inline.highlight.Config: render.md.base.Config
---@field highlight string
---@field custom table<string, render.md.inline.highlight.custom.Config>

---@class (exact) render.md.inline.highlight.custom.Config
---@field prefix string
---@field highlight string

---@type render.md.inline.highlight.Config
M.inline_highlight.default = {
    -- Mimics Obsidian inline highlights when content is surrounded by double equals.
    -- The equals on both ends are concealed and the inner content is highlighted.

    -- Turn on / off inline highlight rendering.
    enabled = true,
    -- Additional modes to render inline highlights.
    render_modes = false,
    -- Applies to background of surrounded text.
    highlight = 'RenderMarkdownInlineHighlight',
    -- Define custom highlights based on text prefix.
    -- The key is for healthcheck and to allow users to change its values, value type below.
    -- | prefix    | matched against text body, @see :h vim.startswith() |
    -- | highlight | highlight for text body                             |
    custom = {},
}

---@return render.md.Schema
function M.inline_highlight.schema()
    ---@type render.md.Schema
    local custom = {
        record = {
            prefix = { type = 'string' },
            highlight = { type = 'string' },
        },
    }
    return M.base.schema({
        highlight = { type = 'string' },
        custom = { map = { { type = 'string' }, custom } },
    })
end

---@class render.md.latex.Settings
M.latex = {}

---@class (exact) render.md.latex.Config: render.md.base.Config
---@field converter string|string[]
---@field highlight string
---@field position render.md.latex.Position
---@field top_pad integer
---@field bottom_pad integer

---@enum render.md.latex.Position
M.latex.position = {
    above = 'above',
    below = 'below',
    center = 'center',
}

---@type render.md.latex.Config
M.latex.default = {
    -- Turn on / off latex rendering.
    enabled = true,
    -- Additional modes to render latex.
    render_modes = false,
    -- Executable used to convert latex formula to rendered unicode.
    -- If a list is provided the commands run in order until the first success.
    converter = { 'utftex', 'latex2text' },
    -- Highlight for latex blocks.
    highlight = 'RenderMarkdownMath',
    -- Determines where latex formula is rendered relative to block.
    -- | above  | above latex block                               |
    -- | below  | below latex block                               |
    -- | center | centered with latex block (must be single line) |
    position = 'center',
    -- Number of empty lines above latex blocks.
    top_pad = 0,
    -- Number of empty lines below latex blocks.
    bottom_pad = 0,
}

---@return render.md.Schema
function M.latex.schema()
    return M.base.schema({
        converter = {
            union = { { list = { type = 'string' } }, { type = 'string' } },
        },
        highlight = { type = 'string' },
        position = { enum = M.latex.position },
        top_pad = { type = 'number' },
        bottom_pad = { type = 'number' },
    })
end

---@class render.md.link.Settings
M.link = {}

---@class (exact) render.md.link.Config: render.md.base.Config
---@field footnote render.md.link.footnote.Config
---@field image string
---@field email string
---@field hyperlink string
---@field highlight string
---@field wiki render.md.link.wiki.Config
---@field custom table<string, render.md.link.custom.Config>

---@class (exact) render.md.link.Context
---@field buf integer
---@field row integer
---@field start_col integer
---@field end_col integer
---@field destination string
---@field alias? string

---@class (exact) render.md.link.footnote.Config
---@field enabled boolean
---@field icon string
---@field superscript boolean
---@field prefix string
---@field suffix string

---@class (exact) render.md.link.wiki.Config
---@field icon string
---@field body fun(ctx: render.md.link.Context): render.md.mark.Text|string?
---@field highlight string
---@field scope_highlight? string

---@class (exact) render.md.link.custom.Config
---@field pattern string
---@field icon string
---@field kind? render.md.link.custom.Kind
---@field priority? integer
---@field highlight? string

---@enum render.md.link.custom.Kind
M.link.kind = {
    pattern = 'pattern',
    suffix = 'suffix',
}

---@type render.md.link.Config
M.link.default = {
    -- Turn on / off inline link icon rendering.
    enabled = true,
    -- Additional modes to render links.
    render_modes = false,
    -- How to handle footnote links, start with a '^'.
    footnote = {
        -- Turn on / off footnote rendering.
        enabled = true,
        -- Inlined with content.
        icon = '󰯔 ',
        -- Replace value with superscript equivalent.
        superscript = true,
        -- Added before link content.
        prefix = '',
        -- Added after link content.
        suffix = '',
    },
    -- Inlined with 'image' elements.
    image = '󰥶 ',
    -- Inlined with 'email_autolink' elements.
    email = '󰀓 ',
    -- Fallback icon for 'inline_link' and 'uri_autolink' elements.
    hyperlink = '󰌹 ',
    -- Applies to the inlined icon as a fallback.
    highlight = 'RenderMarkdownLink',
    -- Applies to WikiLink elements.
    wiki = {
        icon = '󱗖 ',
        body = function()
            return nil
        end,
        highlight = 'RenderMarkdownWikiLink',
        scope_highlight = nil,
    },
    -- Define custom destination patterns so icons can quickly inform you of what a link
    -- contains. Applies to 'inline_link', 'uri_autolink', and wikilink nodes. When multiple
    -- patterns match a link the one with the longer pattern is used.
    -- The key is for healthcheck and to allow users to change its values, value type below.
    -- | pattern   | matched against the destination text                            |
    -- | icon      | gets inlined before the link text                               |
    -- | kind      | optional determines how pattern is checked                      |
    -- |           | pattern | @see :h lua-patterns, is the default if not set       |
    -- |           | suffix  | @see :h vim.endswith()                                |
    -- | priority  | optional used when multiple match, uses pattern length if empty |
    -- | highlight | optional highlight for 'icon', uses fallback highlight if empty |
    custom = {
        web = { pattern = '^http', icon = '󰖟 ' },
        apple = { pattern = 'apple%.com', icon = ' ' },
        discord = { pattern = 'discord%.com', icon = '󰙯 ' },
        github = { pattern = 'github%.com', icon = '󰊤 ' },
        gitlab = { pattern = 'gitlab%.com', icon = '󰮠 ' },
        google = { pattern = 'google%.com', icon = '󰊭 ' },
        hackernews = { pattern = 'ycombinator%.com', icon = ' ' },
        linkedin = { pattern = 'linkedin%.com', icon = '󰌻 ' },
        microsoft = { pattern = 'microsoft%.com', icon = ' ' },
        neovim = { pattern = 'neovim%.io', icon = ' ' },
        reddit = { pattern = 'reddit%.com', icon = '󰑍 ' },
        slack = { pattern = 'slack%.com', icon = '󰒱 ' },
        stackoverflow = { pattern = 'stackoverflow%.com', icon = '󰓌 ' },
        steam = { pattern = 'steampowered%.com', icon = ' ' },
        twitter = { pattern = 'x%.com', icon = ' ' },
        wikipedia = { pattern = 'wikipedia%.org', icon = '󰖬 ' },
        youtube = { pattern = 'youtube[^.]*%.com', icon = '󰗃 ' },
        youtube_short = { pattern = 'youtu%.be', icon = '󰗃 ' },
    },
}

---@return render.md.Schema
function M.link.schema()
    ---@type render.md.Schema
    local pattern = {
        record = {
            pattern = { type = 'string' },
            icon = { type = 'string' },
            kind = { optional = true, enum = M.link.kind },
            priority = { optional = true, type = 'number' },
            highlight = { optional = true, type = 'string' },
        },
    }
    return M.base.schema({
        footnote = {
            record = {
                enabled = { type = 'boolean' },
                icon = { type = 'string' },
                superscript = { type = 'boolean' },
                prefix = { type = 'string' },
                suffix = { type = 'string' },
            },
        },
        image = { type = 'string' },
        email = { type = 'string' },
        hyperlink = { type = 'string' },
        highlight = { type = 'string' },
        wiki = {
            record = {
                icon = { type = 'string' },
                body = { type = 'function' },
                highlight = { type = 'string' },
                scope_highlight = { optional = true, type = 'string' },
            },
        },
        custom = { map = { { type = 'string' }, pattern } },
    })
end

---@class render.md.on.Settings
M.on = {}

---@class (exact) render.md.on.Config
---@field attach fun(ctx: render.md.on.attach.Context)
---@field initial fun(ctx: render.md.on.render.Context)
---@field render fun(ctx: render.md.on.render.Context)
---@field clear fun(ctx: render.md.on.render.Context)

---@class (exact) render.md.on.attach.Context
---@field buf integer

---@class (exact) render.md.on.render.Context
---@field buf integer
---@field win integer

---@type render.md.on.Config
M.on.default = {
    -- Called when plugin initially attaches to a buffer.
    attach = function() end,
    -- Called before adding marks to the buffer for the first time.
    initial = function() end,
    -- Called after plugin renders a buffer.
    render = function() end,
    -- Called after plugin clears a buffer.
    clear = function() end,
}

---@return render.md.Schema
function M.on.schema()
    ---@type render.md.Schema
    return {
        record = {
            attach = { type = 'function' },
            initial = { type = 'function' },
            render = { type = 'function' },
            clear = { type = 'function' },
        },
    }
end

---@class render.md.overrides.Settings
M.overrides = {}

---@class (exact) render.md.overrides.Config
---@field buflisted table<boolean, render.md.partial.UserConfig>
---@field buftype table<string, render.md.partial.UserConfig>
---@field filetype table<string, render.md.partial.UserConfig>
---@field preview render.md.partial.UserConfig

---@type render.md.overrides.Config
M.overrides.default = {
    -- More granular configuration mechanism, allows different aspects of buffers to have their own
    -- behavior. Values default to the top level configuration if no override is provided. Supports
    -- the following fields:
    --   enabled, render_modes, debounce, anti_conceal, bullet, callout, checkbox, code, dash,
    --   document, heading, html, indent, inline_highlight, latex, link, padding, paragraph,
    --   pipe_table, quote, sign, win_options, yaml

    -- Override for different buflisted values, @see :h 'buflisted'.
    buflisted = {},
    -- Override for different buftype values, @see :h 'buftype'.
    buftype = {
        nofile = {
            render_modes = true,
            code = { priority = 175 },
            padding = { highlight = 'NormalFloat' },
            sign = { enabled = false },
        },
    },
    -- Override for different filetype values, @see :h 'filetype'.
    filetype = {},
    -- Override for preview buffer.
    preview = {
        render_modes = true,
    },
}

---@return render.md.Schema
function M.overrides.schema()
    local Config = require('render-markdown.lib.config')
    ---@type render.md.Schema
    return {
        record = {
            buflisted = { map = { { type = 'boolean' }, Config.schema({}) } },
            buftype = { map = { { type = 'string' }, Config.schema({}) } },
            filetype = { map = { { type = 'string' }, Config.schema({}) } },
            preview = Config.schema({}),
        },
    }
end

---@class render.md.padding.Settings
M.padding = {}

---@class (exact) render.md.padding.Config
---@field highlight string

---@type render.md.padding.Config
M.padding.default = {
    -- Highlight to use when adding whitespace, should match background.
    highlight = 'Normal',
}

---@return render.md.Schema
function M.padding.schema()
    ---@type render.md.Schema
    return { record = { highlight = { type = 'string' } } }
end

---@class render.md.paragraph.Settings
M.paragraph = {}

---@class (exact) render.md.paragraph.Config: render.md.base.Config
---@field left_margin render.md.paragraph.Number
---@field indent render.md.paragraph.Number
---@field min_width integer

---@class (exact) render.md.paragraph.Context
---@field text string

---@alias render.md.paragraph.Number
---| number
---| fun(ctx: render.md.paragraph.Context): number

---@type render.md.paragraph.Config
M.paragraph.default = {
    -- Useful context to have when evaluating values.
    -- | text | text value of the node |

    -- Turn on / off paragraph rendering.
    enabled = true,
    -- Additional modes to render paragraphs.
    render_modes = false,
    -- Amount of margin to add to the left of paragraphs.
    -- If a float < 1 is provided it is treated as a percentage of available window space.
    -- Output is evaluated depending on the type.
    -- | function | `value(context)` |
    -- | number   | `value`          |
    left_margin = 0,
    -- Amount of padding to add to the first line of each paragraph.
    -- Output is evaluated using the same logic as 'left_margin'.
    indent = 0,
    -- Minimum width to use for paragraphs.
    min_width = 0,
}

---@return render.md.Schema
function M.paragraph.schema()
    return M.base.schema({
        left_margin = { union = { { type = 'number' }, { type = 'function' } } },
        indent = { union = { { type = 'number' }, { type = 'function' } } },
        min_width = { type = 'number' },
    })
end

---@class render.md.patterns.Settings
M.patterns = {}

---@alias render.md.pattern.Configs table<string, render.md.pattern.Config>

---@class (exact) render.md.pattern.Config
---@field disable boolean
---@field directives render.md.directive.Config[]

---@class (exact) render.md.directive.Config
---@field id integer
---@field name string

---@type render.md.pattern.Configs
M.patterns.default = {
    -- Highlight patterns to disable for filetypes, i.e. lines concealed around code blocks

    markdown = {
        disable = true,
        directives = {
            { id = 17, name = 'conceal_lines' },
            { id = 18, name = 'conceal_lines' },
        },
    },
}

---@return render.md.Schema
function M.patterns.schema()
    ---@type render.md.Schema
    local directive = {
        record = {
            id = { type = 'number' },
            name = { type = 'string' },
        },
    }
    ---@type render.md.Schema
    local pattern = {
        record = {
            disable = { type = 'boolean' },
            directives = { list = directive },
        },
    }
    ---@type render.md.Schema
    return { map = { { type = 'string' }, pattern } }
end

---@class render.md.pipe.table.Settings
M.pipe_table = {}

---@class (exact) render.md.table.Config: render.md.base.Config
---@field preset render.md.table.Preset
---@field cell render.md.table.Cell
---@field cell_offset fun(ctx: render.md.table.cell.Context): integer
---@field padding integer
---@field min_width integer
---@field border string[]
---@field border_enabled boolean
---@field border_virtual boolean
---@field alignment_indicator string
---@field head string
---@field row string
---@field filler string
---@field style render.md.table.Style

---@class (exact) render.md.table.cell.Context
---@field node TSNode

---@enum render.md.table.Preset
M.pipe_table.preset = {
    none = 'none',
    round = 'round',
    double = 'double',
    heavy = 'heavy',
}

---@enum render.md.table.Cell
M.pipe_table.cell = {
    trimmed = 'trimmed',
    padded = 'padded',
    raw = 'raw',
    overlay = 'overlay',
}

---@enum render.md.table.Style
M.pipe_table.style = {
    full = 'full',
    normal = 'normal',
    none = 'none',
}

---@type render.md.table.Config
M.pipe_table.default = {
    -- Turn on / off pipe table rendering.
    enabled = true,
    -- Additional modes to render pipe tables.
    render_modes = false,
    -- Pre configured settings largely for setting table border easier.
    -- | heavy  | use thicker border characters     |
    -- | double | use double line border characters |
    -- | round  | use round border corners          |
    -- | none   | does nothing                      |
    preset = 'none',
    -- Determines how individual cells of a table are rendered.
    -- | overlay | writes completely over the table, removing conceal behavior and highlights |
    -- | raw     | replaces only the '|' characters in each row, leaving the cells unmodified |
    -- | padded  | raw + cells are padded to maximum visual width for each column             |
    -- | trimmed | padded except empty space is subtracted from visual width calculation      |
    cell = 'padded',
    -- Adjust the computed width of table cells using custom logic.
    cell_offset = function()
        return 0
    end,
    -- Amount of space to put between cell contents and border.
    padding = 1,
    -- Minimum column width to use for padded or trimmed cell.
    min_width = 0,
    -- Characters used to replace table border.
    -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal.
    -- stylua: ignore
    border = {
        '┌', '┬', '┐',
        '├', '┼', '┤',
        '└', '┴', '┘',
        '│', '─',
    },
    -- Turn on / off top & bottom lines.
    border_enabled = true,
    -- Always use virtual lines for table borders instead of attempting to use empty lines.
    -- Will be automatically enabled if indentation module is enabled.
    border_virtual = false,
    -- Gets placed in delimiter row for each column, position is based on alignment.
    alignment_indicator = '━',
    -- Highlight for table heading, delimiter, and the line above.
    head = 'RenderMarkdownTableHead',
    -- Highlight for everything else, main table rows and the line below.
    row = 'RenderMarkdownTableRow',
    -- Highlight for inline padding used to add back concealed space.
    filler = 'RenderMarkdownTableFill',
    -- Determines how the table as a whole is rendered.
    -- | none   | { enabled = false }        |
    -- | normal | { border_enabled = false } |
    -- | full   | uses all default values    |
    style = 'full',
}

---@return render.md.Schema
function M.pipe_table.schema()
    return M.base.schema({
        preset = { enum = M.pipe_table.preset },
        cell = { enum = M.pipe_table.cell },
        cell_offset = { type = 'function' },
        padding = { type = 'number' },
        min_width = { type = 'number' },
        border = { list = { type = 'string' } },
        border_enabled = { type = 'boolean' },
        border_virtual = { type = 'boolean' },
        alignment_indicator = { type = 'string' },
        head = { type = 'string' },
        row = { type = 'string' },
        filler = { type = 'string' },
        style = { enum = M.pipe_table.style },
    })
end

---@class render.md.quote.Settings
M.quote = {}

---@class (exact) render.md.quote.Config: render.md.base.Config
---@field icon string|string[]
---@field repeat_linebreak boolean
---@field highlight string|string[]

---@type render.md.quote.Config
M.quote.default = {
    -- Turn on / off block quote & callout rendering.
    enabled = true,
    -- Additional modes to render quotes.
    render_modes = false,
    -- Replaces '>' of 'block_quote'.
    icon = '▋',
    -- Whether to repeat icon on wrapped lines. Requires neovim >= 0.10. This will obscure text
    -- if incorrectly configured with :h 'showbreak', :h 'breakindent' and :h 'breakindentopt'.
    -- A combination of these that is likely to work follows.
    -- | showbreak      | '  ' (2 spaces)   |
    -- | breakindent    | true              |
    -- | breakindentopt | '' (empty string) |
    -- These are not validated by this plugin. If you want to avoid adding these to your main
    -- configuration then set them in win_options for this plugin.
    repeat_linebreak = false,
    -- Highlight for the quote icon.
    -- If a list is provided output is evaluated by `cycle(value, level)`.
    highlight = {
        'RenderMarkdownQuote1',
        'RenderMarkdownQuote2',
        'RenderMarkdownQuote3',
        'RenderMarkdownQuote4',
        'RenderMarkdownQuote5',
        'RenderMarkdownQuote6',
    },
}

---@return render.md.Schema
function M.quote.schema()
    return M.base.schema({
        icon = {
            union = { { list = { type = 'string' } }, { type = 'string' } },
        },
        repeat_linebreak = { type = 'boolean' },
        highlight = {
            union = { { list = { type = 'string' } }, { type = 'string' } },
        },
    })
end

---@class render.md.sign.Settings
M.sign = {}

---@class (exact) render.md.sign.Config
---@field enabled boolean
---@field highlight string

---@type render.md.sign.Config
M.sign.default = {
    -- Turn on / off sign rendering.
    enabled = true,
    -- Applies to background of sign text.
    highlight = 'RenderMarkdownSign',
}

---@return render.md.Schema
function M.sign.schema()
    ---@type render.md.Schema
    return {
        record = {
            enabled = { type = 'boolean' },
            highlight = { type = 'string' },
        },
    }
end

---@class render.md.win.options.Settings
M.win_options = {}

---@alias render.md.window.Configs table<string, render.md.window.Config>

---@class (exact) render.md.window.Config
---@field default render.md.option.Value
---@field rendered render.md.option.Value

---@alias render.md.option.Value number|integer|string|boolean

---@type render.md.window.Configs
M.win_options.default = {
    -- Window options to use that change between rendered and raw view.

    -- @see :h 'conceallevel'
    conceallevel = {
        -- Used when not being rendered, get user setting.
        default = vim.o.conceallevel,
        -- Used when being rendered, concealed text is completely hidden.
        rendered = 3,
    },
    -- @see :h 'concealcursor'
    concealcursor = {
        -- Used when not being rendered, get user setting.
        default = vim.o.concealcursor,
        -- Used when being rendered, show concealed text in all modes.
        rendered = '',
    },
}

---@return render.md.Schema
function M.win_options.schema()
    ---@type render.md.Schema
    local value = {
        union = {
            { type = 'number' },
            { type = 'string' },
            { type = 'boolean' },
        },
    }
    ---@type render.md.Schema
    local option = { record = { default = value, rendered = value } }
    ---@type render.md.Schema
    return { map = { { type = 'string' }, option } }
end

---@class render.md.yaml.Settings
M.yaml = {}

---@class (exact) render.md.yaml.Config: render.md.base.Config

---@type render.md.yaml.Config
M.yaml.default = {
    -- Turn on / off all yaml rendering.
    enabled = true,
    -- Additional modes to render yaml.
    render_modes = false,
}

---@return render.md.Schema
function M.yaml.schema()
    return M.base.schema({})
end

return M
