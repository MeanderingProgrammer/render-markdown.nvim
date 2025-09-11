local compat = require('render-markdown.lib.compat')
local env = require('render-markdown.lib.env')
local interval = require('render-markdown.lib.interval')
local str = require('render-markdown.lib.str')

---@class render.md.request.conceal.Line
---@field hidden boolean
---@field ranges render.md.request.conceal.Range[]

---@class render.md.request.conceal.Range: render.md.Range
---@field [3] string replacement
---@field [4] integer blocks

---@class render.md.request.Conceal
---@field private buf integer
---@field private level integer
---@field private view render.md.request.View
---@field private computed boolean
---@field private lines table<integer, render.md.request.conceal.Line>
local Conceal = {}
Conceal.__index = Conceal

---@param buf integer
---@param win integer
---@param view render.md.request.View
---@return render.md.request.Conceal
function Conceal.new(buf, win, view)
    local self = setmetatable({}, Conceal)
    self.buf = buf
    self.level = env.win.get(win, 'conceallevel')
    self.view = view
    self.computed = false
    self.lines = {}
    return self
end

---@return boolean
function Conceal:enabled()
    return self.level > 0
end

---@param row integer
---@param entry boolean|render.md.request.conceal.Range
function Conceal:add(row, entry)
    if not self:enabled() then
        return
    end
    if not self.lines[row] then
        self.lines[row] = { hidden = false, ranges = {} }
    end
    local line = self.lines[row]
    if type(entry) == 'boolean' then
        line.hidden = entry
    else
        if interval.valid(entry, true) then
            line.ranges[#line.ranges + 1] = entry
            line.ranges = Conceal.coalesce(line.ranges)
        end
    end
end

---@private
---@param ranges render.md.request.conceal.Range[]
---@return render.md.request.conceal.Range[]
function Conceal.coalesce(ranges)
    interval.sort(ranges)
    local result = {} ---@type render.md.request.conceal.Range[]
    result[#result + 1] = ranges[1]
    for i = 2, #ranges do
        local range, last = ranges[i], result[#result]
        if range[1] <= last[2] then
            last[2] = math.max(last[2], range[2])
            last[3] = last[3] .. range[3]
            last[4] = last[4] + range[4]
        else
            result[#result + 1] = range
        end
    end
    return result
end

---@param s string
---@param blocks integer
---@return integer
function Conceal:width(s, blocks)
    if self.level == 1 then
        -- each block is replaced with one character
        return blocks
    elseif self.level == 2 then
        -- replacement characters width is used
        return str.width(s)
    else
        -- text is completely hidden
        return 0
    end
end

---@param body render.md.node.Body
---@return boolean
function Conceal:hidden(body)
    -- conceal lines metadata require neovim >= 0.11.0 to function
    return compat.has_11 and self:line(body).hidden
end

---@param body render.md.node.Body
---@return integer
function Conceal:get(body)
    local result = 0
    local target = { body.start_col, body.end_col } ---@type render.md.Range
    for _, range in ipairs(self:line(body).ranges) do
        local overlap = interval.overlap(range, target, true)
        if overlap then
            local text = body.text:sub(
                overlap[1] - target[1] + 1,
                overlap[2] - target[1]
            )
            local width = str.width(text) - self:width(range[3], range[4])
            result = result + width
        end
    end
    return result
end

---@private
---@param body render.md.node.Body
---@return render.md.request.conceal.Line
function Conceal:line(body)
    if not self.computed then
        self.computed = true
        self:compute()
    end
    local line = self.lines[body.start_row]
    if not line then
        line = { hidden = false, ranges = {} }
    end
    return line
end

---Cached row level implementation of vim.treesitter.get_captures_at_pos
---@private
function Conceal:compute()
    if not self:enabled() then
        return
    end
    if not vim.treesitter.highlighter.active[self.buf] then
        return
    end
    local parser = vim.treesitter.get_parser(self.buf)
    if not parser then
        return
    end
    parser:for_each_tree(function(tree, language_tree)
        self:tree(language_tree:lang(), tree:root())
    end)
end

---@private
---@param language string
---@param root TSNode
function Conceal:tree(language, root)
    if not self.view:overlaps(root) then
        return
    end
    if not vim.tbl_contains({ 'markdown', 'markdown_inline' }, language) then
        return
    end
    local query = vim.treesitter.query.get(language, 'highlights')
    if not query then
        return
    end
    self.view:query(root, query, function(id, node, data)
        if data.conceal_lines then
            local row = Conceal.range(id, node, data)
            self:add(row, true)
        end
        if data.conceal then
            local row, start_col, _, end_col = Conceal.range(id, node, data)
            self:add(row, { start_col, end_col, data.conceal, 1 })
        end
    end)
end

---@private
---@param id integer
---@param node TSNode
---@param data vim.treesitter.query.TSMetadata
---@return integer, integer, integer, integer
function Conceal.range(id, node, data)
    local range = data.range
    if range then
        return range[1], range[2], range[3], range[4]
    end
    range = data[id] and data[id].range or nil
    if range then
        return range[1], range[2], range[3], range[4]
    end
    return node:range()
end

return Conceal
