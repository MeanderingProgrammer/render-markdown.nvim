---@class render.md.Api
local M = {}

function M.enable()
    require('render-markdown.core.manager').set_all(true)
end

function M.buf_enable()
    require('render-markdown.core.manager').set_buf(nil, true)
end

function M.disable()
    require('render-markdown.core.manager').set_all(false)
end

function M.buf_disable()
    require('render-markdown.core.manager').set_buf(nil, false)
end

function M.toggle()
    require('render-markdown.core.manager').set_all(nil)
end

function M.buf_toggle()
    require('render-markdown.core.manager').set_buf(nil, nil)
end

function M.log()
    require('render-markdown.core.log').open()
end

function M.expand()
    require('render-markdown.state').modify_anti_conceal(1)
    M.enable()
end

function M.contract()
    require('render-markdown.state').modify_anti_conceal(-1)
    M.enable()
end

function M.debug()
    require('render-markdown.debug.marks').show()
end

function M.config()
    local difference = require('render-markdown.state').difference()
    if not difference then
        -- selene: allow(deprecated)
        vim.print('default configuration')
    else
        -- selene: allow(deprecated)
        vim.print(difference)
    end
end

return M
