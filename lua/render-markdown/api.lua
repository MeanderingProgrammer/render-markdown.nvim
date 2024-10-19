local manager = require('render-markdown.manager')
local state = require('render-markdown.state')
local util = require('render-markdown.core.util')

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
    local buf, win = util.current('buf'), util.current('win')
    local row, marks = require('render-markdown.core.ui').get_row_marks(buf, win)
    require('render-markdown.debug.marks').debug(row, marks)
end

function M.config()
    local difference = state.difference(require('render-markdown').default_config)
    if vim.tbl_count(difference) == 0 then
        vim.print('Default Configuration')
    else
        vim.print(difference)
    end
end

return M
