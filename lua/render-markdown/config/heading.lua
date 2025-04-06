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

---@enum (key) render.md.heading.Position
local Position = {
    overlay = 'overlay',
    inline = 'inline',
    right = 'right',
}

---@enum (key) render.md.heading.Width
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
        :type('setext', 'boolean')
        :type('sign', 'boolean')
        :list('icons', 'string', 'function')
        :one_of('position', vim.tbl_keys(Position))
        :list('signs', 'string')
        :one_or_list_of('width', vim.tbl_keys(Width))
        :list('left_margin', 'number', 'number')
        :list('left_pad', 'number', 'number')
        :list('right_pad', 'number', 'number')
        :list('min_width', 'number', 'number')
        :list('border', 'boolean', 'boolean')
        :type('border_virtual', 'boolean')
        :type('border_prefix', 'boolean')
        :type('above', 'string')
        :type('below', 'string')
        :list('backgrounds', 'string')
        :list('foregrounds', 'string')
        :nested('custom', function(customs)
            customs
                :each(function(custom)
                    custom
                        :type('pattern', 'string')
                        :type('icon', { 'string', 'nil' })
                        :type('background', { 'string', 'nil' })
                        :type('foreground', { 'string', 'nil' })
                        :check()
                end, false)
                :check()
        end)
        :check()
end

return M
