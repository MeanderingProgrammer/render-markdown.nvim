---@class (exact) render.md.quote.Config: render.md.base.Config
---@field icon string|string[]
---@field repeat_linebreak boolean
---@field highlight string|string[]

---@class render.md.quote
local M = {}

---@type render.md.quote.Config
M.default = {
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

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    local Base = require('render-markdown.config.base')
    Base.validate(spec)
    spec:list('icon', 'string', 'string')
    spec:type('repeat_linebreak', 'boolean')
    spec:list('highlight', 'string', 'string')
    spec:check()
end

return M
