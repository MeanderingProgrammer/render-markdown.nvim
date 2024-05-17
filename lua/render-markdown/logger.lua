local state = require('render-markdown.state')

-- Typically resolves to ~/.local/state/nvim/render-markdown.log
local log_file = vim.fn.stdpath('state') .. '/render-markdown.log'

---@class render.md.LogEntry
---@field date string
---@field level string
---@field message string

---@class render.md.Log
---@field entries render.md.LogEntry[]
local log = {
    entries = {},
}

log.reset = function()
    log.entries = {}
end

---@param level string
---@param message any
log.add = function(level, message)
    ---@type render.md.LogEntry
    local entry = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        date = os.date('%Y-%m-%d %H:%M:%S'),
        level = string.upper(level),
        message = vim.inspect(message),
    }
    table.insert(log.entries, entry)
end

log.flush = function()
    if #log.entries == 0 then
        return
    end
    local file = assert(io.open(log_file, 'w'))
    for _, entry in ipairs(log.entries) do
        local line = string.format('%s - %s - %s', entry.date, entry.level, entry.message)
        file:write(line .. '\n')
    end
    file:close()
    log.reset()
end

local M = {}

M.start = function()
    log.reset()
end

---@param message any
M.debug = function(message)
    if vim.tbl_contains({ 'debug' }, state.config.log_level) then
        log.add('debug', message)
    end
end

---@param capture string
---@param node TSNode
M.debug_node = function(capture, node)
    if vim.tbl_contains({ 'debug' }, state.config.log_level) then
        local value = vim.treesitter.get_node_text(node, 0)
        local start_row, start_col, end_row, end_col = node:range()
        log.add('debug', {
            capture = capture,
            value = value,
            rows = { start_row, end_row },
            cols = { start_col, end_col },
        })
    end
end

---@param message any
M.error = function(message)
    if vim.tbl_contains({ 'debug', 'error' }, state.config.log_level) then
        log.add('error', message)
    end
end

M.flush = function()
    log.flush()
end

return M
