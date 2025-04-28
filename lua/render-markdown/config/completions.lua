---@class (exact) render.md.completions.Config
---@field blink render.md.completion.Config
---@field coq render.md.completion.Config
---@field lsp render.md.completion.Config
---@field filter render.md.completion.filter.Config

---@class (exact) render.md.completion.Config
---@field enabled boolean

---@class (exact) render.md.completion.filter.Config
---@field callout fun(value: render.md.callout.Config): boolean
---@field checkbox fun(value: render.md.checkbox.custom.Config): boolean

---@class render.md.completions
local M = {}

---@type render.md.completions.Config
M.default = {
    -- Settings for blink.cmp completions source
    blink = { enabled = false },
    -- Settings for coq_nvim completions source
    coq = { enabled = false },
    -- Settings for in-process language server completions
    lsp = { enabled = false },
    filter = {
        callout = function()
            -- example to exclude obsidian callouts
            -- return value.category ~= 'obsidian'
            return true
        end,
        checkbox = function()
            return true
        end,
    },
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:nested({ 'blink', 'coq', 'lsp' }, function(completion)
        completion:type('enabled', 'boolean')
        completion:check()
    end)
    spec:nested('filter', function(filter)
        filter:type('callout', 'function')
        filter:type('checkbox', 'function')
        filter:check()
    end)
    spec:check()
end

return M
