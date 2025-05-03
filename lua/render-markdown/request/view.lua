local Env = require('render-markdown.lib.env')
local Node = require('render-markdown.lib.node')
local Range = require('render-markdown.lib.range')
local log = require('render-markdown.core.log')

---@class render.md.request.View
---@field private buf integer
---@field private ranges render.md.Range[]
local View = {}
View.__index = View

---@param buf integer
---@return render.md.request.View
function View.new(buf)
    local self = setmetatable({}, View)
    self.buf = buf
    local ranges = {} ---@type render.md.Range[]
    for _, win in ipairs(Env.buf.windows(buf)) do
        local top, bottom = Env.range(buf, win, 10)
        ranges[#ranges + 1] = Range.new(top, bottom)
    end
    self.ranges = Range.coalesce(ranges)
    return self
end

---@return string
function View:__tostring()
    local ranges = {} ---@type string[]
    for _, range in ipairs(self.ranges) do
        ranges[#ranges + 1] = tostring(range)
    end
    return ('[%s]'):format(table.concat(ranges, ','))
end

---@param win integer
---@return boolean
function View:contains(win)
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
function View:overlaps(node)
    local top, _, bottom, _ = node:range()
    for _, range in ipairs(self.ranges) do
        if range:overlaps(top, bottom) then
            return true
        end
    end
    return false
end

---@param parser vim.treesitter.LanguageTree
function View:parse(parser)
    for _, range in ipairs(self.ranges) do
        parser:parse({ range.top, range.bottom })
    end
end

---@param root TSNode
---@param query vim.treesitter.Query
---@param callback fun(capture: string, node: render.md.Node)
function View:query(root, query, callback)
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
function View:for_each(callback)
    for _, range in ipairs(self.ranges) do
        callback(range)
    end
end

return View
