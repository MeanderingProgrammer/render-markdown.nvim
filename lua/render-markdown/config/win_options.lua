---@class (exact) render.md.window.Config
---@field default render.md.option.Value
---@field rendered render.md.option.Value

---@alias render.md.option.Value number|integer|string|boolean

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:each(function(option)
        option
            :type('default', { 'number', 'string', 'boolean' })
            :type('rendered', { 'number', 'string', 'boolean' })
            :check()
    end, false):check()
end

return M
