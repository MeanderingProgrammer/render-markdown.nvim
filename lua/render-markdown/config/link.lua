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
---@field superscript boolean
---@field prefix string
---@field suffix string

---@class (exact) render.md.link.wiki.Config
---@field icon string
---@field body fun(ctx: render.md.link.Context): render.md.mark.Text|string?
---@field highlight string

---@class (exact) render.md.link.custom.Config
---@field pattern string
---@field icon string
---@field highlight? string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:nested('footnote', function(footnote)
        footnote:type('enabled', 'boolean')
        footnote:type('superscript', 'boolean')
        footnote:type('prefix', 'string')
        footnote:type('suffix', 'string')
        footnote:check()
    end)
    spec:type('image', 'string')
    spec:type('email', 'string')
    spec:type('hyperlink', 'string')
    spec:type('highlight', 'string')
    spec:nested('wiki', function(wiki)
        wiki:type('icon', 'string')
        wiki:type('body', 'function')
        wiki:type('highlight', 'string')
        wiki:check()
    end)
    spec:nested('custom', function(patterns)
        patterns:each(function(pattern)
            pattern:type('pattern', 'string')
            pattern:type('icon', 'string')
            pattern:type('highlight', { 'string', 'nil' })
            pattern:check()
        end, false)
        patterns:check()
    end)
    spec:check()
end

return M
