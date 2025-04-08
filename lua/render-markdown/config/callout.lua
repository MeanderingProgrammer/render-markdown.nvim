---@class (exact) render.md.callout.Config
---@field raw string
---@field rendered string
---@field highlight string
---@field quote_icon? string
---@field category? string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:each(function(callout)
        callout:type('raw', 'string')
        callout:type('rendered', 'string')
        callout:type('highlight', 'string')
        callout:type('quote_icon', { 'string', 'nil' })
        callout:type('category', { 'string', 'nil' })
        callout:check()
    end, false)
    spec:check()
end

return M
