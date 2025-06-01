local Compat = require('render-markdown.lib.compat')
local Context = require('render-markdown.request.context')
local Decorator = require('render-markdown.lib.decorator')
local Env = require('render-markdown.lib.env')
local Extmark = require('render-markdown.lib.extmark')
local Iter = require('render-markdown.lib.iter')
local Range = require('render-markdown.lib.range')
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
---@type table<integer, render.md.Decorator>
M.cache = {}

---called from state on setup
---@param config render.md.ui.Config
function M.setup(config)
    M.config = config
    -- clear marks and reset cache
    for buf in pairs(M.cache) do
        vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
    end
    M.cache = {}
end

---@param buf integer
---@return render.md.Decorator
function M.get(buf)
    local result = M.cache[buf]
    if not result then
        result = Decorator.new(buf)
        M.cache[buf] = result
    end
    return result
end

---Used by fzf-lua: https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/previewer/builtin.lua
---@param buf integer
---@param win integer
---@param event string
---@param force boolean
function M.update(buf, win, event, force)
    log.buf('info', 'Update', buf, event, ('force %s'):format(force))
    M.updater.new(buf, win, force):start()
end

---@class render.md.ui.Updater
---@field private buf integer
---@field private win integer
---@field private force boolean
---@field private decorator render.md.Decorator
---@field private config render.md.buf.Config
---@field private mode string
local Updater = {}
Updater.__index = Updater

---@param buf integer
---@param win integer
---@param force boolean
---@return render.md.ui.Updater
function Updater.new(buf, win, force)
    local self = setmetatable({}, Updater)
    self.buf = buf
    self.win = win
    self.force = force
    self.decorator = M.get(buf)
    self.config = state.get(buf)
    return self
end

function Updater:start()
    if not Env.valid(self.buf, self.win) then
        return
    end
    if Env.buf.empty(self.buf) then
        return
    end
    self.decorator:schedule(
        self:changed(),
        self.config.debounce,
        log.runtime('update', function()
            self:run()
        end)
    )
end

---@private
---@return boolean
function Updater:changed()
    -- force or buffer has changed or we have not handled the visible range yet
    return self.force
        or self.decorator:changed()
        or not Context.contains(self.buf, self.win)
end

---@private
function Updater:run()
    if not Env.valid(self.buf, self.win) then
        return
    end
    self.mode = Env.mode.get() -- mode is only available after this point
    local render = self.config.enabled
        and self.config.resolved:render(self.mode)
        and not Env.win.get(self.win, 'diff')
        and Env.win.view(self.win).leftcol == 0
    log.buf('info', 'Render', self.buf, render)
    local next_state = render and 'rendered' or 'default'
    for _, win in ipairs(Env.buf.windows(self.buf)) do
        for name, value in pairs(self.config.win_options) do
            Env.win.set(win, name, value[next_state])
        end
    end
    if not render then
        self:clear()
        M.config.on.clear({ buf = self.buf, win = self.win })
    else
        self:render()
        M.config.on.render({ buf = self.buf, win = self.win })
    end
end

---@private
function Updater:clear()
    local extmarks = self.decorator:get()
    for _, extmark in ipairs(extmarks) do
        extmark:hide(M.ns, self.buf)
    end
end

---@private
function Updater:render()
    if self:changed() then
        local initial = self.decorator:initial()
        self:clear()
        local extmarks = self:get_extmarks()
        self.decorator:set(extmarks)
        if initial then
            Compat.fix_lsp_window(self.buf, self.win, extmarks)
            M.config.on.initial({ buf = self.buf, win = self.win })
        end
    end
    local range = self:hidden()
    local extmarks = self.decorator:get()
    for _, extmark in ipairs(extmarks) do
        if extmark:get().conceal and extmark:overlaps(range) then
            extmark:hide(M.ns, self.buf)
        else
            extmark:show(M.ns, self.buf)
        end
    end
end

---@private
---@return render.md.Extmark[]
function Updater:get_extmarks()
    local ok, parser = pcall(vim.treesitter.get_parser, self.buf)
    if not ok or not parser then
        log.buf('error', 'Fail', self.buf, 'no treesitter parser found')
        return {}
    end
    -- reset buffer context
    local context = Context.new(self.buf, self.win, self.config, self.mode)
    -- make sure injections are processed
    context.view:parse(parser)
    local marks = handlers.run(context, parser)
    return Iter.list.map(marks, Extmark.new)
end

---@private
---@return render.md.Range?
function Updater:hidden()
    -- anti-conceal is not enabled -> hide nothing
    -- row is not known -> buffer is not active -> hide nothing
    -- in command mode -> cursor is not in buffer -> hide nothing
    local config = self.config.anti_conceal
    local row = Env.row.get(self.buf, self.win)
    if not config.enabled or not row or Env.mode.is(self.mode, { 'c' }) then
        return nil
    end
    if Env.mode.is(self.mode, { 'v', 'V', '\22' }) then
        local start = vim.fn.getpos('v')[2] - 1
        return Range.new(math.min(row, start), math.max(row, start))
    else
        return Range.new(row - config.above, row + config.below)
    end
end

---@private
M.updater = Updater

return M
