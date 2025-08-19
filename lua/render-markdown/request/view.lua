local Node = require('render-markdown.lib.node')
local env = require('render-markdown.lib.env')
local interval = require('render-markdown.lib.interval')
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
        ranges[#ranges + 1] = env.range(buf, win, 10)
    end
    self.ranges = interval.coalesce(ranges)
    return self
end

---@return string
function View:__tostring()
    local ranges = {} ---@type string[]
    for _, range in ipairs(self.ranges) do
        ranges[#ranges + 1] = ('%d->%d'):format(range[1], range[2])
    end
    return ('[%s]'):format(table.concat(ranges, ','))
end

---@param win integer
---@return boolean
function View:contains(win)
    local rows = env.range(self.buf, win, 0)
    for _, range in ipairs(self.ranges) do
        if interval.contains(range, rows) then
            return true
        end
    end
    return false
end

---@param node TSNode
---@return boolean
function View:overlaps(node)
    local start_row, _, end_row = node:range()
    for _, range in ipairs(self.ranges) do
        if interval.overlaps(range, { start_row, end_row }) then
            return true
        end
    end
    return false
end

---@param parser vim.treesitter.LanguageTree
---@param callback fun()
function View:parse(parser, callback)
    for _, range in ipairs(self.ranges) do
        parser:parse({ range[1], range[2] })
    end
    callback()
end

---@param root TSNode
---@param query vim.treesitter.Query
---@param callback fun(capture: string, node: render.md.Node)
function View:nodes(root, query, callback)
    self:query(root, query, function(id, ts_node)
        if not ts_node:has_error() then
            local capture = query.captures[id]
            local node = Node.new(self.buf, ts_node)
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
        local start, stop = range[1], range[2]
        for id, node, data in query:iter_captures(root, self.buf, start, stop) do
            callback(id, node, data)
        end
    end
end

return View
