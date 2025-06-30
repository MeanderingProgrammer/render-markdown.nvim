local Node = require('render-markdown.lib.node')
local Range = require('render-markdown.lib.range')
local env = require('render-markdown.lib.env')
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
    for _, win in ipairs(env.buf.windows(buf)) do
        local top, bottom = env.range(buf, win, 10)
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
    local top, bottom = env.range(self.buf, win, 0)
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
function View:nodes(root, query, callback)
    self:query(root, query, function(id, ts)
        if not ts:has_error() then
            local capture = query.captures[id]
            local node = Node.new(self.buf, ts)
            log.node(capture, node)
            callback(capture, node)
        end
    end)
end

---@param root TSNode
---@param query vim.treesitter.Query
---@param callback fun(id: integer, node: TSNode, data: vim.treesitter.query.TSMetadata)
function View:query(root, query, callback)
    for _, range in ipairs(self.ranges) do
        local top, bottom = range.top, range.bottom
        for id, node, data in query:iter_captures(root, self.buf, top, bottom) do
            callback(id, node, data)
        end
    end
end

return View
