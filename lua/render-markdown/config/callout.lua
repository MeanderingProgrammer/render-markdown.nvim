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
        callout
            :type('raw', 'string')
            :type('rendered', 'string')
            :type('highlight', 'string')
            :type('quote_icon', { 'string', 'nil' })
            :type('category', { 'string', 'nil' })
            :check()
    end, false):check()
end

return M
