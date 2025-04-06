---@class (exact) render.md.overrides.Config
---@field buflisted table<boolean, render.md.buffer.UserConfig>
---@field buftype table<string, render.md.buffer.UserConfig>
---@field filetype table<string, render.md.buffer.UserConfig>

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:nested({ 'buflisted', 'buftype', 'filetype' }, function(overrides)
        overrides
            :each(function(override)
                require('render-markdown.config').validate(override):check()
            end, true)
            :check()
    end):check()
end

return M
