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
---@field name string
---@field message string

---@class render.md.Log
local log = {
    ---@type render.md.LogEntry[]
    entries = {},
}

function log.reset()
    log.entries = {}
end

---@param level string
---@param name string
---@param message any
function log.add(level, name, message)
    ---@type render.md.LogEntry
    local entry = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        date = os.date('%Y-%m-%d %H:%M:%S'),
        level = string.upper(level),
        name = name,
        message = convert_message(message),
    }
    table.insert(log.entries, entry)
end

function log.flush()
    if #log.entries == 0 then
        return
    end
    local file = assert(io.open(log_file, 'w'))
    for _, entry in ipairs(log.entries) do
        local line = string.format('%s [%s] %s: %s', entry.date, entry.level, entry.name, entry.message)
        file:write(line .. '\n')
    end
    file:close()
    log.reset()
end

---@class render.md.Logger
local M = {}

function M.start()
    log.reset()
end

---@param name string
---@param message any
function M.debug(name, message)
    if vim.tbl_contains({ 'debug' }, state.config.log_level) then
        log.add('debug', name, message)
    end
end

---@private
---@param name string
---@param message any
function M.error(name, message)
    if vim.tbl_contains({ 'debug', 'error' }, state.config.log_level) then
        log.add('error', name, message)
    end
end

---@param capture string
---@param info render.md.NodeInfo
function M.debug_node_info(capture, info)
    M.debug('node info', {
        capture = capture,
        text = info.text,
        rows = { info.start_row, info.end_row },
        cols = { info.start_col, info.end_col },
    })
end

---Encountered if user provides custom capture
---@param group string
---@param capture string
function M.unhandled_capture(group, capture)
    M.error('unhandled capture', string.format('%s -> %s', group, capture))
end

---Encountered if new type is seen for a particular group
---@param language string
---@param group string
---@param value string
function M.unhandled_type(language, group, value)
    M.error('unhandled type', string.format('%s -> %s -> %s', language, group, value))
end

function M.flush()
    log.flush()
end

return M
