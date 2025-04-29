local manager = require('render-markdown.manager')
local state = require('render-markdown.state')

---@class render.md.Api
local M = {}

function M.enable()
    manager.set_all(true)
end

function M.buf_enable()
    manager.set_current(true)
end

function M.disable()
    manager.set_all(false)
end

function M.buf_disable()
    manager.set_current(false)
end

function M.toggle()
    manager.set_all()
end

function M.buf_toggle()
    manager.set_current()
end

function M.log()
    require('render-markdown.core.log').open()
end

function M.expand()
    state.modify_anti_conceal(1)
    M.enable()
end

function M.contract()
    state.modify_anti_conceal(-1)
    M.enable()
end

function M.debug()
    require('render-markdown.debug.marks').show()
end

function M.config()
    local difference = state.difference()
    if not difference then
        -- selene: allow(deprecated)
        vim.print('default configuration')
    else
        -- selene: allow(deprecated)
        vim.print(difference)
    end
end

return M
