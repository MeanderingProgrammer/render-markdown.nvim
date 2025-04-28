---@class render.md.custom.handlers
local M = {}

---@type table<string, render.md.Handler>
M.default = {
    -- Mapping from treesitter language to user defined handlers.
    -- @see [Custom Handlers](doc/custom-handlers.md)
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:each(function(handler)
        handler:type('extends', { 'boolean', 'nil' })
        handler:type('parse', 'function')
        handler:check()
    end)
    spec:check()
end

return M
