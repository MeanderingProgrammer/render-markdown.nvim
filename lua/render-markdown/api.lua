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
    local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
    local row, marks = require('render-markdown.core.ui').get_row_marks(buf, win)
    require('render-markdown.debug.marks').debug(row, marks)
end

return M
