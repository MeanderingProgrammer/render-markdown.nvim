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

---@param root render.md.Config
---@param buf integer
---@return render.md.main.Config
function Config.new(root, buf)
    ---@type render.md.buffer.Config
    local config = {
        enabled = true,
        render_modes = root.render_modes,
        max_file_size = root.max_file_size,
        debounce = root.debounce,
        anti_conceal = root.anti_conceal,
        bullet = root.bullet,
        callout = root.callout,
        checkbox = root.checkbox,
        code = root.code,
        dash = root.dash,
        document = root.document,
        heading = root.heading,
        html = root.html,
        indent = root.indent,
        inline_highlight = root.inline_highlight,
        latex = root.latex,
        link = root.link,
        padding = root.padding,
        paragraph = root.paragraph,
        pipe_table = root.pipe_table,
        quote = root.quote,
        sign = root.sign,
        win_options = root.win_options,
    }
    config = vim.deepcopy(config)
    for _, name in ipairs({ 'buflisted', 'buftype', 'filetype' }) do
        local value = Env.buf.get(buf, name)
        local override = root.overrides[name][value]
        if override ~= nil then
            config = vim.tbl_deep_extend('force', config, override)
        end
    end

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

-- stylua: ignore
---@param spec render.md.debug.ValidatorSpec
function Config.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('max_file_size', 'number')
    spec:type('debounce', 'number')
    spec:nested('anti_conceal', require('render-markdown.config.anti_conceal').validate)
    spec:nested('bullet', require('render-markdown.config.bullet').validate)
    spec:nested('callout', require('render-markdown.config.callout').validate)
    spec:nested('checkbox', require('render-markdown.config.checkbox').validate)
    spec:nested('code', require('render-markdown.config.code').validate)
    spec:nested('dash', require('render-markdown.config.dash').validate)
    spec:nested('document', require('render-markdown.config.document').validate)
    spec:nested('heading', require('render-markdown.config.heading').validate)
    spec:nested('html', require('render-markdown.config.html').validate)
    spec:nested('indent', require('render-markdown.config.indent').validate)
    spec:nested('inline_highlight', require('render-markdown.config.inline_highlight').validate)
    spec:nested('latex', require('render-markdown.config.latex').validate)
    spec:nested('link', require('render-markdown.config.link').validate)
    spec:nested('padding', require('render-markdown.config.padding').validate)
    spec:nested('paragraph', require('render-markdown.config.paragraph').validate)
    spec:nested('pipe_table', require('render-markdown.config.pipe_table').validate)
    spec:nested('quote', require('render-markdown.config.quote').validate)
    spec:nested('sign', require('render-markdown.config.sign').validate)
    spec:nested('win_options', require('render-markdown.config.win_options').validate)
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
    if Env.mode.is(mode, { 'v', 'V', '\22' }) then
        local start = vim.fn.getpos('v')[2] - 1
        return Range.new(math.min(row, start), math.max(row, start))
    else
        return Range.new(row - config.above, row + config.below)
    end
end

return Config
