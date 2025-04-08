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
        footnote
            :type('enabled', 'boolean')
            :type('superscript', 'boolean')
            :type('prefix', 'string')
            :type('suffix', 'string')
            :check()
    end)
        :type('image', 'string')
        :type('email', 'string')
        :type('hyperlink', 'string')
        :type('highlight', 'string')
        :nested('wiki', function(wiki)
            wiki:type('icon', 'string')
                :type('body', 'function')
                :type('highlight', 'string')
                :check()
        end)
        :nested('custom', function(patterns)
            patterns
                :each(function(pattern)
                    pattern
                        :type('pattern', 'string')
                        :type('icon', 'string')
                        :type('highlight', { 'string', 'nil' })
                        :check()
                end, false)
                :check()
        end)
        :check()
end

return M
