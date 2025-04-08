local Env = require('render-markdown.lib.env')
local Range = require('render-markdown.core.range')

---@class render.md.Components
---@field callout table<string, render.md.callout.Config>
---@field checkbox table<string, render.md.checkbox.custom.Config>

---@class render.md.BufferConfig: render.md.buffer.Config
---@field private modes render.md.Modes
---@field private components render.md.Components
local Config = {}
Config.__index = Config

---@param config render.md.buffer.Config
---@return render.md.BufferConfig
function Config.new(config)
    -- Super set of render modes across top level and individual components
    local modes = config.render_modes
    for _, component in pairs(config) do
        if type(component) == 'table' then
            modes = Config.fold_modes(modes, component['render_modes'])
        end
    end

    ---@type render.md.Components
    local components = {
        callout = Config.normalize(config.callout),
        checkbox = Config.normalize(config.checkbox.custom),
    }

    local instance = vim.tbl_deep_extend(
        'force',
        { modes = modes, components = components },
        config
    )
    return setmetatable(instance, Config)
end

---@param spec render.md.debug.ValidatorSpec
---@return render.md.debug.ValidatorSpec
function Config.validate(spec)
    require('render-markdown.config.base').validate(spec)
    return spec:type('max_file_size', 'number')
        :type('debounce', 'number')
        :nested(
            'anti_conceal',
            require('render-markdown.config.anti_conceal').validate
        )
        :nested('bullet', require('render-markdown.config.bullet').validate)
        :nested('callout', require('render-markdown.config.callout').validate)
        :nested('checkbox', require('render-markdown.config.checkbox').validate)
        :nested('code', require('render-markdown.config.code').validate)
        :nested('dash', require('render-markdown.config.dash').validate)
        :nested('heading', require('render-markdown.config.heading').validate)
        :nested('html', require('render-markdown.config.html').validate)
        :nested('indent', require('render-markdown.config.indent').validate)
        :nested(
            'inline_highlight',
            require('render-markdown.config.inline_highlight').validate
        )
        :nested('latex', require('render-markdown.config.latex').validate)
        :nested('link', require('render-markdown.config.link').validate)
        :nested('padding', require('render-markdown.config.padding').validate)
        :nested(
            'paragraph',
            require('render-markdown.config.paragraph').validate
        )
        :nested(
            'pipe_table',
            require('render-markdown.config.pipe_table').validate
        )
        :nested('quote', require('render-markdown.config.quote').validate)
        :nested('sign', require('render-markdown.config.sign').validate)
        :nested(
            'win_options',
            require('render-markdown.config.win_options').validate
        )
end

---@private
---@param current render.md.Modes
---@param new? render.md.Modes
---@return render.md.Modes
function Config.fold_modes(current, new)
    if type(current) == 'boolean' and type(new) == 'boolean' then
        return current or new
    elseif type(current) == 'boolean' and type(new) == 'table' then
        return current or new
    elseif type(current) == 'table' and type(new) == 'boolean' then
        return new or current
    elseif type(current) == 'table' and type(new) == 'table' then
        -- Copy to avoid modifying inputs
        local result = {}
        vim.list_extend(result, current)
        vim.list_extend(result, new)
        return result
    else
        -- Should only occur if new is nil, keep current value
        return current
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
    return Env.mode.is(mode, self.modes)
end

---@param node render.md.Node
---@return render.md.callout.Config?
function Config:get_callout(node)
    return self.components.callout[node.text:lower()]
end

---@param node render.md.Node
---@return render.md.checkbox.custom.Config?
function Config:get_checkbox(node)
    return self.components.checkbox[node.text:lower()]
end

---@param mode string
---@param row? integer
---@return render.md.Range?
function Config:hidden(mode, row)
    -- Anti-conceal is not enabled -> hide nothing
    -- Row is not known means buffer is not active -> hide nothing
    if not self.anti_conceal.enabled or row == nil then
        return nil
    end
    if vim.tbl_contains({ 'v', 'V', '\22' }, mode) then
        local start = vim.fn.getpos('v')[2] - 1
        return Range.new(math.min(row, start), math.max(row, start))
    else
        return Range.new(
            row - self.anti_conceal.above,
            row + self.anti_conceal.below
        )
    end
end

return Config
