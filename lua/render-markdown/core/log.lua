local env = require('render-markdown.lib.env')

---@class render.md.log.Entry
---@field date string
---@field level string
---@field name string
---@field message string

---@class render.md.log.Config
---@field level render.md.log.Level
---@field runtime boolean

---@enum (key) render.md.log.Level
local Level = {
    trace = 0,
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
    off = 5,
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
    if env.file_size_mb(M.file) > 5 then
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
            local compat = require('render-markdown.lib.compat')
            local start_time = compat.uv.hrtime()
            callback()
            local end_time = compat.uv.hrtime()
            local elapsed = (end_time - start_time) / 1e+6
            assert(elapsed < 1000, 'invalid elapsed time')
            -- selene: allow(deprecated)
            vim.print(('%8s : %5.1f ms'):format(name:upper(), elapsed))
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
    M.add('trace', 'Node', {
        capture = capture,
        type = node.type,
        length = #node.text,
        rows = { node.start_row, node.end_row },
        cols = { node.start_col, node.end_col },
    })
end

---@param buf integer
---@param ... string
function M.attach(buf, ...)
    M.buf('info', 'Attach', buf, ...)
end

---Encountered if new type is seen in a particular node
---@param buf integer
---@param ... string
function M.unhandled(buf, ...)
    M.buf('error', 'UnhandledType', buf, table.concat({ ... }, ' -> '))
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
    if not env.buf.valid(buf) then
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
    local messages = {} ---@type string[]
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
---@return number
function M.level(level)
    return Level[level] or math.huge
end

---@private
function M.flush()
    if #M.entries == 0 then
        return
    end
    local file = assert(io.open(M.file, 'a'))
    for _, entry in ipairs(M.entries) do
        local line = ('%s %s [%s] - %s'):format(
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
