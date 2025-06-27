---@alias render.md.pattern.Configs table<string, render.md.pattern.Config>

---@class (exact) render.md.pattern.Config
---@field disable boolean
---@field directives render.md.directive.Config[]

---@class (exact) render.md.directive.Config
---@field id integer
---@field name string

---@class render.md.pattern.Cfg
local M = {}

---@type render.md.pattern.Configs
M.default = {
    -- Highlight patterns to disable for filetypes, i.e. lines concealed around code blocks

    markdown = {
        disable = true,
        directives = {
            { id = 17, name = 'conceal_lines' },
            { id = 18, name = 'conceal_lines' },
        },
    },
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:each(function(pattern)
        pattern:type('disable', 'boolean')
        pattern:nested('directives', function(directives)
            directives:each(function(directive)
                directive:type('id', 'number')
                directive:type('name', 'string')
                directive:check()
            end)
            directives:check()
        end)
        pattern:check()
    end)
    spec:check()
end

return M
