local Env = require('render-markdown.lib.env')
local Range = require('render-markdown.core.range')

---@class render.md.main.Full
---@field modes render.md.Modes
---@field callout table<string, render.md.callout.Config>
---@field checkbox table<string, render.md.checkbox.custom.Config>

---@class render.md.main.Config: render.md.buffer.Config
---@field private full render.md.main.Full
local Config = {}
Config.__index = Config

---@param config render.md.buffer.Config
---@return render.md.main.Config
function Config.new(config)
    -- super set of render modes across top level and individual components
    local modes = config.render_modes
    for _, component in pairs(config) do
        if type(component) == 'table' then
            modes = Config.fold(modes, component['render_modes'])
        end
    end

    ---@type render.md.main.Full
    local full = {
        modes = modes,
        callout = Config.normalize(config.callout),
        checkbox = Config.normalize(config.checkbox.custom),
    }

    local instance = vim.tbl_deep_extend('force', { full = full }, config)
    return setmetatable(instance, Config)
end

---@param spec render.md.debug.ValidatorSpec
function Config.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('max_file_size', 'number')
    spec:type('debounce', 'number')
    spec:config('anti_conceal')
    spec:config('bullet')
    spec:config('callout')
    spec:config('checkbox')
    spec:config('code')
    spec:config('dash')
    spec:config('document')
    spec:config('heading')
    spec:config('html')
    spec:config('indent')
    spec:config('inline_highlight')
    spec:config('latex')
    spec:config('link')
    spec:config('padding')
    spec:config('paragraph')
    spec:config('pipe_table')
    spec:config('quote')
    spec:config('sign')
    spec:config('win_options')
end

---@private
---@param acc render.md.Modes
---@param new? render.md.Modes
---@return render.md.Modes
function Config.fold(acc, new)
    if type(acc) == 'boolean' and type(new) == 'boolean' then
        return acc or new
    elseif type(acc) == 'boolean' and type(new) == 'table' then
        return acc or new
    elseif type(acc) == 'table' and type(new) == 'boolean' then
        return new or acc
    elseif type(acc) == 'table' and type(new) == 'table' then
        -- copy to avoid modifying inputs
        local result = {}
        vim.list_extend(result, acc)
        vim.list_extend(result, new)
        return result
    else
        -- should only occur if new is nil, keep current value
        return acc
    end
end

---@private
---@generic T: render.md.callout.Config|render.md.checkbox.custom.Config
---@param components table<string, T>
---@return table<string, T>
function Config.normalize(components)
    local result = {}
    for _, component in pairs(components) do
        result[component.raw:lower()] = component
    end
    return result
end

---@param mode string
---@return boolean
function Config:render(mode)
    return Env.mode.is(mode, self.full.modes)
end

---@param node render.md.Node
---@return render.md.callout.Config?
function Config:get_callout(node)
    return self.full.callout[node.text:lower()]
end

---@param node render.md.Node
---@return render.md.checkbox.custom.Config?
function Config:get_checkbox(node)
    return self.full.checkbox[node.text:lower()]
end

---@param mode string
---@param row? integer
---@return render.md.Range?
function Config:hidden(mode, row)
    -- anti-conceal is not enabled -> hide nothing
    -- row is not known -> buffer is not active -> hide nothing
    local config = self.anti_conceal
    if not config.enabled or row == nil then
        return nil
    end
    if vim.tbl_contains({ 'v', 'V', '\22' }, mode) then
        local start = vim.fn.getpos('v')[2] - 1
        return Range.new(math.min(row, start), math.max(row, start))
    else
        return Range.new(row - config.above, row + config.below)
    end
end

return Config
