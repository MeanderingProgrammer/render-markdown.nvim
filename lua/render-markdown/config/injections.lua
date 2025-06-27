---@alias render.md.injection.Configs table<string, render.md.injection.Config>

---@class (exact) render.md.injection.Config
---@field enabled boolean
---@field query string

---@class render.md.injection.Cfg
local M = {}

---@type render.md.injection.Configs
M.default = {
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

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:each(function(injection)
        injection:type('enabled', 'boolean')
        injection:type('query', 'string')
        injection:check()
    end)
    spec:check()
end

return M
