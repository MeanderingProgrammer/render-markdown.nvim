local Buffer = require('render-markdown.lib.buffer')
local Compat = require('render-markdown.lib.compat')
local Context = require('render-markdown.request.context')
local Env = require('render-markdown.lib.env')
local Extmark = require('render-markdown.lib.extmark')
local Iter = require('render-markdown.lib.iter')
local handlers = require('render-markdown.core.handlers')
local log = require('render-markdown.core.log')
local state = require('render-markdown.state')

---@class render.md.ui.Config
---@field on render.md.on.Config

---@class render.md.Ui
---@field private config render.md.ui.Config
local M = {}

M.ns = vim.api.nvim_create_namespace('render-markdown.nvim')

---@private
---@type table<integer, render.md.Buffer>
M.cache = {}

---called from state on setup
---@param config render.md.ui.Config
function M.setup(config)
    M.config = config
    -- reset cache
    for buf, buffer in pairs(M.cache) do
        M.clear_buffer(buf, buffer)
    end
    M.cache = {}
end

---@param buf integer
---@return render.md.Buffer
function M.get(buf)
    local result = M.cache[buf]
    if not result then
        result = Buffer.new(buf)
        M.cache[buf] = result
    end
    return result
end

---Used by fzf-lua: https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/previewer/builtin.lua
---@param buf integer
---@param win integer
---@param event string
---@param change boolean
function M.update(buf, win, event, change)
    log.buf('info', 'update', buf, event, ('change %s'):format(change))
    if not Env.valid(buf, win) then
        return
    end

    local parse = M.parse(buf, win, change)
    local config = state.get(buf)
    local buffer = M.get(buf)
    if buffer:is_empty() then
        return
    end

    local update = log.runtime('update', function()
        M.run_update(buf, win, change)
    end)
    buffer:run(parse, config.debounce, update)
end

---@private
---@param buf integer
---@param win integer
---@param change boolean
function M.run_update(buf, win, change)
    if not Env.valid(buf, win) then
        return
    end

    local parse = M.parse(buf, win, change)
    local config = state.get(buf)
    local buffer = M.get(buf)
    local mode = Env.mode.get()
    local row = Env.row.get(buf, win)

    local render = state.enabled
        and config.enabled
        and config:render(mode)
        and not Env.win.get(win, 'diff')
        and Env.win.view(win).leftcol == 0

    log.buf('info', 'render', buf, render)
    local next_state = render and 'rendered' or 'default'
    for _, window in ipairs(Env.buf.windows(buf)) do
        for name, value in pairs(config.win_options) do
            Env.win.set(window, name, value[next_state])
        end
    end

    if render then
        local initial = buffer:initial()
        if initial or parse then
            M.clear_buffer(buf, buffer)
            local extmarks = M.parse_buffer(buf, win, config, mode)
            buffer:set_marks(extmarks)
            if initial then
                Compat.fix_lsp_window(buf, win, extmarks)
                M.config.on.initial({ buf = buf, win = win })
            end
        end
        local range = config:hidden(mode, row)
        local extmarks = buffer:get_marks()
        for _, extmark in ipairs(extmarks) do
            if extmark:get().conceal and extmark:overlaps(range) then
                extmark:hide(M.ns, buf)
            else
                extmark:show(M.ns, buf)
            end
        end
        M.config.on.render({ buf = buf, win = win })
    else
        M.clear_buffer(buf, buffer)
        M.config.on.clear({ buf = buf, win = win })
    end
end

---@private
---@param buf integer
---@param win integer
---@param change boolean
---@return boolean
function M.parse(buf, win, change)
    -- need to parse when things change or we have not parsed the visible range yet
    return change or not Context.contains(buf, win)
end

---@private
---@param buf integer
---@param buffer render.md.Buffer
function M.clear_buffer(buf, buffer)
    vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
    buffer:set_marks(nil)
end

---@private
---@param buf integer
---@param win integer
---@param config render.md.main.Config
---@param mode string
---@return render.md.Extmark[]
function M.parse_buffer(buf, win, config, mode)
    local has_parser, parser = pcall(vim.treesitter.get_parser, buf)
    if not has_parser or not parser then
        log.buf('error', 'fail', buf, 'no treesitter parser found')
        return {}
    end
    -- reset buffer context
    local context = Context.start(buf, win, config, mode)
    -- make sure injections are processed
    context.view:parse(parser)
    local marks = handlers.run(context, parser)
    return Iter.list.map(marks, Extmark.new)
end

return M
