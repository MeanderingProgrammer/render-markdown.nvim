local manager = require('render-markdown.manager')
local profiler = require('render-markdown.profiler')
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

function M.stats()
    profiler.dump_stats()
end

return M
