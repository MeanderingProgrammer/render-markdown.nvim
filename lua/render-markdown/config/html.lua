---@class (exact) render.md.html.Config: render.md.base.Config
---@field comment render.md.html.comment.Config
---@field tag table<string, render.md.html.Tag>

---@class (exact) render.md.html.comment.Config
---@field conceal boolean
---@field text? string
---@field highlight string

---@class (exact) render.md.html.Tag
---@field icon string
---@field highlight string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:nested('comment', function(comment)
        comment:type('conceal', 'boolean')
        comment:type('text', { 'string', 'nil' })
        comment:type('highlight', 'string')
        comment:check()
    end)
    spec:nested('tag', function(tags)
        tags:each(function(tag)
            tag:type('icon', 'string')
            tag:type('highlight', 'string')
            tag:check()
        end, false)
        tags:check()
    end)
    spec:check()
end

return M
