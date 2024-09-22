local util = require('render-markdown.core.util')

---@class render.md.log.Entry
---@field date string
---@field level string
---@field name string
---@field message string

---@class render.md.Log
---@field private level render.md.config.LogLevel
---@field private entries render.md.log.Entry[]
---@field file string
local M = {}

---@param level render.md.config.LogLevel
function M.setup(level)
    -- Write out any logs before closing
    vim.api.nvim_create_autocmd('VimLeave', {
        group = vim.api.nvim_create_augroup('RenderMarkdownLog', { clear = true }),
        callback = M.flush,
    })
    M.level = level
    M.entries = {}
    -- Typically resolves to ~/.local/state/nvim/render-markdown.log
    M.file = vim.fn.stdpath('state') .. '/render-markdown.log'
    -- Clear the file contents if it is too big
    if util.file_size_mb(M.file) > 5 then
        assert(io.open(M.file, 'w')):close()
    end
end

---@param capture string
---@param info render.md.NodeInfo
function M.node_info(capture, info)
    M.add('debug', 'node info', {
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
    M.add('error', 'unhandled capture', string.format('%s -> %s', group, capture))
end

---Encountered if new type is seen for a particular group
---@param language string
---@param group string
---@param value string
function M.unhandled_type(language, group, value)
    M.add('error', 'unhandled type', string.format('%s -> %s -> %s', language, group, value))
end

---@param level render.md.config.LogLevel
---@param name string
---@param buf integer
---@param ... any
function M.buf(level, name, buf, ...)
    M.add(level, string.format('%s %d', name, buf), ...)
end

---@param level render.md.config.LogLevel
---@param name string
---@param ... any
function M.add(level, name, ...)
    if M.level_value(level) < M.level_value(M.level) then
        return
    end
    local messages = {}
    local args = vim.F.pack_len(...)
    for i = 1, args.n do
        local message = type(args[i]) == 'string' and args[i] or vim.inspect(args[i])
        table.insert(messages, message)
    end
    ---@type render.md.log.Entry
    local entry = {
        date = vim.fn.strftime('%Y-%m-%d %H:%M:%S'),
        level = string.upper(level),
        name = name,
        message = table.concat(messages, ' | '),
    }
    table.insert(M.entries, entry)
    -- Periodically flush logs to disk
    if #M.entries > 1000 then
        M.flush()
    end
end

---@private
---@param level render.md.config.LogLevel
---@return integer
function M.level_value(level)
    if level == 'debug' then
        return 1
    elseif level == 'info' then
        return 2
    elseif level == 'error' then
        return 3
    else
        return 0
    end
end

function M.flush()
    if #M.entries == 0 then
        return
    end
    local file = assert(io.open(M.file, 'a'))
    for _, entry in ipairs(M.entries) do
        local line = string.format('%s %s [%s] - %s', entry.date, entry.level, entry.name, entry.message)
        file:write(line .. '\n')
    end
    file:close()
    M.entries = {}
end

return M
