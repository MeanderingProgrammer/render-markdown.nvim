---@module 'luassert'

local stub = require('luassert.stub')

---@class render.md.test.Task: vim.SystemObj
---@field private stdout string
local Task = {}
Task.__index = Task

---@param stdout string
---@return render.md.test.Task
function Task.new(stdout)
    local self = setmetatable({}, Task)
    self.stdout = stdout
    return self
end

---@return vim.SystemCompleted
function Task:wait()
    ---@type vim.SystemCompleted
    return { code = 0, signal = 0, stdout = self.stdout }
end

---@class render.md.test.System
local M = {}

---@param command string
---@param outputs table<string, string>
function M.mock(command, outputs)
    stub.new(vim.fn, 'executable', function(expr)
        assert.same(command, expr)
        return 1
    end)
    stub.new(vim, 'system', function(cmd, opts)
        assert.same({ command }, cmd)
        local output = outputs[opts.stdin]
        assert.not_nil(output, ('missing output: %s'):format(opts.stdin))
        return Task.new(output)
    end)
end

return M
