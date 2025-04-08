---@class (exact) render.md.overrides.Config
---@field buflisted table<boolean, render.md.buffer.UserConfig>
---@field buftype table<string, render.md.buffer.UserConfig>
---@field filetype table<string, render.md.buffer.UserConfig>

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:nested({ 'buflisted', 'buftype', 'filetype' }, function(overrides)
        overrides:each(function(override)
            require('render-markdown.config').validate(override)
            override:check()
        end, true)
        overrides:check()
    end)
    spec:check()
end

return M
