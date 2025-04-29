local Conceal = require('render-markdown.core.conceal')
local Env = require('render-markdown.lib.env')
local Node = require('render-markdown.lib.node')
local Range = require('render-markdown.core.range')
local Str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')

---@class render.md.context.Props
---@field buf integer
---@field win integer
---@field config render.md.main.Config
---@field mode string

---@class render.md.context.Offset
---@field col integer
---@field width integer

---@class render.md.Context: render.md.context.Props
---@field private ranges render.md.Range[]
---@field private callouts table<integer, render.md.callout.Config>
---@field private checkboxes table<integer, render.md.checkbox.custom.Config>
---@field private offsets table<integer, render.md.context.Offset[]>
---@field conceal render.md.Conceal
---@field last_heading? integer
local Context = {}
Context.__index = Context

---@param props render.md.context.Props
---@param offset integer
---@return render.md.Context
function Context.new(props, offset)
    local self = setmetatable({}, Context)

    local ranges = {}
    for _, window in ipairs(Env.buf.windows(props.buf)) do
        local top, bottom = Env.range(props.buf, window, offset)
        ranges[#ranges + 1] = Range.new(top, bottom)
    end
    self.ranges = Range.coalesce(ranges)
    self.callouts = {}
    self.checkboxes = {}
    self.offsets = {}

    self.buf = props.buf
    self.win = props.win
    self.config = props.config
    self.mode = props.mode

    self.conceal = Conceal.new(self)
    self.last_heading = nil

    return self
end

---@param config render.md.base.Config
---@return boolean
function Context:skip(config)
    -- Skip disabled config regardless of mode
    if not config.enabled then
        return true
    end
    -- Enabled config in top level modes should not be skipped
    if Env.mode.is(self.mode, self.config.render_modes) then
        return false
    end
    -- Enabled config in config modes should not be skipped
    return not Env.mode.is(self.mode, config.render_modes)
end

---@param row integer
---@return render.md.callout.Config?
function Context:get_callout(row)
    return self.callouts[row]
end

---@param row integer
---@param callout render.md.callout.Config
function Context:add_callout(row, callout)
    self.callouts[row] = callout
end

---@param row integer
---@return render.md.checkbox.custom.Config?
function Context:get_checkbox(row)
    return self.checkboxes[row]
end

---@param row integer
---@param checkbox render.md.checkbox.custom.Config
function Context:add_checkbox(row, checkbox)
    self.checkboxes[row] = checkbox
end

---@param node? render.md.Node
---@return integer
function Context:width(node)
    if not node then
        return 0
    end
    return Str.width(node.text) + self:get_offset(node) - self.conceal:get(node)
end

---@private
---@param node render.md.Node
---@return integer
function Context:get_offset(node)
    local result = 0
    local offsets = self.offsets[node.start_row] or {}
    for _, offset in ipairs(offsets) do
        if node.start_col <= offset.col and node.end_col > offset.col then
            result = result + offset.width
        end
    end
    return result
end

---@param row integer
---@param offset render.md.context.Offset
function Context:add_offset(row, offset)
    if offset.width <= 0 then
        return
    end
    if not self.offsets[row] then
        self.offsets[row] = {}
    end
    local offsets = self.offsets[row]
    offsets[#offsets + 1] = offset
end

---@param value number
---@param used integer
---@return integer
function Context:percent(value, used)
    if value <= 0 then
        return 0
    elseif value < 1 then
        local available = Env.win.width(self.win) - used
        return math.floor((available * value) + 0.5)
    else
        return value
    end
end

---@param win integer
---@return boolean
function Context:contains(win)
    local top, bottom = Env.range(self.buf, win, 0)
    for _, range in ipairs(self.ranges) do
        if range:contains(top, bottom) then
            return true
        end
    end
    return false
end

---@param node TSNode
---@return boolean
function Context:overlaps(node)
    local top, _, bottom, _ = node:range()
    for _, range in ipairs(self.ranges) do
        if range:overlaps(top, bottom) then
            return true
        end
    end
    return false
end

---@param parser vim.treesitter.LanguageTree
function Context:parse(parser)
    for _, range in ipairs(self.ranges) do
        parser:parse({ range.top, range.bottom })
    end
end

---@param root TSNode
---@param query vim.treesitter.Query
---@param callback fun(capture: string, node: render.md.Node)
function Context:query(root, query, callback)
    for _, range in ipairs(self.ranges) do
        local top, bottom = range.top, range.bottom
        for id, ts_node in query:iter_captures(root, self.buf, top, bottom) do
            local capture = query.captures[id]
            local node = Node.new(self.buf, ts_node)
            log.node(capture, node)
            callback(capture, node)
        end
    end
end

---@param callback fun(range: render.md.Range)
function Context:for_each(callback)
    for _, range in ipairs(self.ranges) do
        callback(range)
    end
end

---@class render.md.context.Manager
local M = {}

---@private
---@type table<integer, render.md.Context>
M.cache = {}

---@param buf integer
---@param win integer
---@return boolean
function M.contains(buf, win)
    local context = M.cache[buf]
    return context and context:contains(win) or false
end

---@param props render.md.context.Props
---@return render.md.Context
function M.reset(props)
    local context = Context.new(props, 10)
    M.cache[props.buf] = context
    return context
end

---@param buf integer
---@return render.md.Context
function M.get(buf)
    return assert(M.cache[buf], 'missing context')
end

return M
