---@class (exact) render.md.heading.Config: render.md.base.Config
---@field atx boolean
---@field setext boolean
---@field sign boolean
---@field icons render.md.heading.Icons
---@field position render.md.heading.Position
---@field signs string[]
---@field width render.md.heading.Width|(render.md.heading.Width)[]
---@field left_margin number|number[]
---@field left_pad number|number[]
---@field right_pad number|number[]
---@field min_width integer|integer[]
---@field border boolean|boolean[]
---@field border_virtual boolean
---@field border_prefix boolean
---@field above string
---@field below string
---@field backgrounds string[]
---@field foregrounds string[]
---@field custom table<string, render.md.heading.Custom>

---@class (exact) render.md.heading.Context
---@field level integer
---@field sections integer[]

---@alias render.md.heading.Icons
---| string[]
---| fun(ctx: render.md.heading.Context): string?

---@enum render.md.heading.Position
local Position = {
    overlay = 'overlay',
    inline = 'inline',
    right = 'right',
}

---@enum render.md.heading.Width
local Width = {
    full = 'full',
    block = 'block',
}

---@class (exact) render.md.heading.Custom
---@field pattern string
---@field icon? string
---@field background? string
---@field foreground? string

local M = {}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    require('render-markdown.config.base').validate(spec)
    spec:type('atx', 'boolean')
    spec:type('setext', 'boolean')
    spec:type('sign', 'boolean')
    spec:list('icons', 'string', 'function')
    spec:one_of('position', vim.tbl_values(Position))
    spec:list('signs', 'string')
    spec:one_or_list_of('width', vim.tbl_values(Width))
    spec:list('left_margin', 'number', 'number')
    spec:list('left_pad', 'number', 'number')
    spec:list('right_pad', 'number', 'number')
    spec:list('min_width', 'number', 'number')
    spec:list('border', 'boolean', 'boolean')
    spec:type('border_virtual', 'boolean')
    spec:type('border_prefix', 'boolean')
    spec:type('above', 'string')
    spec:type('below', 'string')
    spec:list('backgrounds', 'string')
    spec:list('foregrounds', 'string')
    spec:nested('custom', function(customs)
        customs:each(function(custom)
            custom:type('pattern', 'string')
            custom:type('icon', { 'string', 'nil' })
            custom:type('background', { 'string', 'nil' })
            custom:type('foreground', { 'string', 'nil' })
            custom:check()
        end, false)
        customs:check()
    end)
    spec:check()
end

return M
