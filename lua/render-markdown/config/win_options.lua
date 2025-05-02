---@class (exact) render.md.window.Config
---@field default render.md.option.Value
---@field rendered render.md.option.Value

---@alias render.md.option.Value number|integer|string|boolean

---@class render.md.window.Cfg
local M = {}

---@type table<string, render.md.window.Config>
M.default = {
    -- Window options to use that change between rendered and raw view.

    -- @see :h 'conceallevel'
    conceallevel = {
        -- Used when not being rendered, get user setting.
        default = vim.o.conceallevel,
        -- Used when being rendered, concealed text is completely hidden.
        rendered = 3,
    },
    -- @see :h 'concealcursor'
    concealcursor = {
        -- Used when not being rendered, get user setting.
        default = vim.o.concealcursor,
        -- Used when being rendered, show concealed text in all modes.
        rendered = '',
    },
}

---@param spec render.md.debug.ValidatorSpec
function M.validate(spec)
    spec:each(function(option)
        option:type('default', { 'number', 'string', 'boolean' })
        option:type('rendered', { 'number', 'string', 'boolean' })
        option:check()
    end, false)
    spec:check()
end

return M
