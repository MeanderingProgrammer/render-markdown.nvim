local Env = require('render-markdown.lib.env')

---@class render.md.log.Entry
---@field date string
---@field level string
---@field name string
---@field message string

---@class render.md.log.Config
---@field level render.md.log.Level
---@field runtime boolean

---@enum render.md.log.Level
local Level = {
    debug = 'debug',
    info = 'info',
    error = 'error',
    off = 'off',
}

---@class render.md.Log
---@field private file string
---@field private entries render.md.log.Entry[]
---@field private config render.md.log.Config
local M = {}

---called from state on setup
---@param config render.md.log.Config
function M.setup(config)
    -- typically resolves to ~/.local/state/nvim/render-markdown.log
    M.file = vim.fn.stdpath('state') .. '/render-markdown.log'
    M.entries = {}
    M.config = config
end

---called from plugin directory
function M.init()
    -- clear the file contents if it is too big
    if Env.file_size_mb(M.file) > 5 then
        assert(io.open(M.file, 'w')):close()
    end
    -- write out any logs before closing
    vim.api.nvim_create_autocmd('VimLeave', {
        group = vim.api.nvim_create_augroup('RenderMarkdownLog', {}),
        callback = M.flush,
    })
end

---@param name string
---@param callback fun()
---@return fun()
function M.runtime(name, callback)
    if M.config.runtime then
        return function()
            local Compat = require('render-markdown.lib.compat')
            local start_time = Compat.uv.hrtime()
            callback()
            local end_time = Compat.uv.hrtime()
            local elapsed = (end_time - start_time) / 1e+6
            assert(elapsed < 1000)
            vim.print(string.format('%8s : %5.1f ms', name:upper(), elapsed))
        end
    else
        return callback
    end
end

function M.open()
    M.flush()
    vim.cmd.tabnew(M.file)
end

---@param capture string
---@param node render.md.Node
function M.node(capture, node)
    M.add('debug', 'node', {
        capture = capture,
        text = node.text,
        rows = { node.start_row, node.end_row },
        cols = { node.start_col, node.end_col },
    })
end

---Encountered if new type is seen for a particular group
---@param language string
---@param group string
---@param value string
function M.unhandled_type(language, group, value)
    local message = string.format('%s -> %s -> %s', language, group, value)
    M.add('error', 'unhandled type', message)
end

---@param level render.md.log.Level
---@param name string
---@param buf integer
---@param ... any
function M.buf(level, name, buf, ...)
    M.add(level, name, buf, M.file_name(buf), ...)
end

---@private
---@param buf integer
---@return string
function M.file_name(buf)
    if not Env.buf.valid(buf) then
        return 'INVALID'
    end
    local file = vim.api.nvim_buf_get_name(buf)
    local name = vim.fn.fnamemodify(file, ':t')
    return #name == 0 and 'EMPTY' or name
end

---@param level render.md.log.Level
---@param name string
---@param ... any
function M.add(level, name, ...)
    if M.level(level) < M.level(M.config.level) then
        return
    end
    local messages = {}
    for i = 1, select('#', ...) do
        local value = select(i, ...)
        local message = type(value) == 'string' and value or vim.inspect(value)
        messages[#messages + 1] = message
    end
    ---@type render.md.log.Entry
    local entry = {
        date = vim.fn.strftime('%Y-%m-%d %H:%M:%S'),
        level = string.upper(level),
        name = name,
        message = table.concat(messages, ' | '),
    }
    M.entries[#M.entries + 1] = entry
    -- periodically flush logs to disk
    if #M.entries > 1000 then
        M.flush()
    end
end

---@private
---@param level render.md.log.Level
---@return integer
function M.level(level)
    if level == Level.debug then
        return 1
    elseif level == Level.info then
        return 2
    elseif level == Level.error then
        return 3
    elseif level == Level.off then
        return 4
    else
        return 0
    end
end

---@private
function M.flush()
    if #M.entries == 0 then
        return
    end
    local file = assert(io.open(M.file, 'a'))
    for _, entry in ipairs(M.entries) do
        local line = string.format(
            '%s %s [%s] - %s',
            entry.date,
            entry.level,
            entry.name,
            entry.message
        )
        file:write(line .. '\n')
    end
    file:close()
    M.entries = {}
end

return M
