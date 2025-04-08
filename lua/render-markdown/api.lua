local Env = require('render-markdown.lib.env')
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
    local log = require('render-markdown.core.log')
    log.open()
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
    local ui = require('render-markdown.core.ui')
    local disply = require('render-markdown.debug.marks')
    local buf = Env.buf.current()
    local win = Env.win.current()
    local row, marks = ui.get_row_marks(buf, win)
    disply.show(row, marks)
end

function M.config()
    local markdown = require('render-markdown')
    local difference = state.difference(markdown.default)
    if vim.tbl_count(difference) == 0 then
        vim.print('Default Configuration')
    else
        vim.print(difference)
    end
end

return M
