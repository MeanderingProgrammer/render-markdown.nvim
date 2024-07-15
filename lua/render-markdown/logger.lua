local state = require('render-markdown.state')

-- Typically resolves to ~/.local/state/nvim/render-markdown.log
local log_file = vim.fn.stdpath('state') .. '/render-markdown.log'

---@param message any
---@return string
local function convert_message(message)
    if type(message) == 'string' then
        return message
    else
        return vim.inspect(message)
    end
end

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
        message = convert_message(message),
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

---@class render.md.Logger
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

---@param message any
M.error = function(message)
    if vim.tbl_contains({ 'debug', 'error' }, state.config.log_level) then
        log.add('error', message)
    end
end

---@param capture string
---@param info render.md.NodeInfo
M.debug_node_info = function(capture, info)
    M.debug({
        capture = capture,
        text = info.text,
        rows = { info.start_row, info.end_row },
        cols = { info.start_col, info.end_col },
    })
end

---Encountered if user provides custom capture
---@param group string
---@param capture string
M.unhandled_capture = function(group, capture)
    M.error(string.format('Unhandled %s capture: %s', group, capture))
end

---Encountered if new type is seen for a particular group
---@param language string
---@param group string
---@param value string
M.unhandled_type = function(language, group, value)
    M.error(string.format('Unhandled %s %s type: %s', language, group, value))
end

M.flush = function()
    log.flush()
end

return M
