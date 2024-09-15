local log = require('render-markdown.core.log')
local manager = require('render-markdown.manager')
local state = require('render-markdown.state')

---@class render.md.Api
local M = {}

function M.enable()
    manager.set_all(true)
end

function M.disable()
    manager.set_all(false)
end

function M.toggle()
    manager.set_all(not state.enabled)
end

function M.log()
    log.flush()
    vim.cmd.tabnew(log.file)
end

function M.expand()
    state.modify_anti_conceal(1)
    M.enable()
end

function M.contract()
    state.modify_anti_conceal(-1)
    M.enable()
end

return M
