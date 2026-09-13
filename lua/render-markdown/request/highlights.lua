local interval = require('render-markdown.lib.interval')

---@class render.md.request.highlights.Line
---@field hidden boolean
---@field conceals render.md.request.highlights.Conceal[]

---@class render.md.request.highlights.Entry
---@field hidden? boolean
---@field conceal? render.md.request.highlights.Conceal

---@class render.md.request.highlights.Conceal: render.md.Range
---@field replacement string
---@field blocks integer

---@class render.md.request.Highlights
---@field private buf integer
---@field private view render.md.request.View
---@field private computed boolean
---@field private lines table<integer, render.md.request.highlights.Line>
local Highlights = {}
Highlights.__index = Highlights

---@param buf integer
---@param view render.md.request.View
---@return render.md.request.Highlights
function Highlights.new(buf, view)
    local self = setmetatable({}, Highlights)
    self.buf = buf
    self.view = view
    self.computed = false
    self.lines = {}
    return self
end

---@param row integer
---@param entry render.md.request.highlights.Entry
function Highlights:add(row, entry)
    if not self.lines[row] then
        self.lines[row] = { hidden = false, conceals = {} }
    end
    local line = self.lines[row]
    if entry.hidden then
        line.hidden = entry.hidden
    end
    if entry.conceal then
        if interval.valid(entry.conceal, true) then
            line.conceals[#line.conceals + 1] = entry.conceal
            line.conceals = Highlights.coalesce_conceals(line.conceals)
        end
    end
end

---@private
---@param conceals render.md.request.highlights.Conceal[]
---@return render.md.request.highlights.Conceal[]
function Highlights.coalesce_conceals(conceals)
    interval.sort(conceals)
    local result = {} ---@type render.md.request.highlights.Conceal[]
    result[#result + 1] = conceals[1]
    for i = 2, #conceals do
        local conceal, last = conceals[i], result[#result]
        if conceal[1] <= last[2] then
            last[2] = math.max(last[2], conceal[2])
            last.replacement = last.replacement .. conceal.replacement
            last.blocks = last.blocks + conceal.blocks
        else
            result[#result + 1] = conceal
        end
    end
    return result
end

---@param row integer
---@return render.md.request.highlights.Line
function Highlights:line(row)
    if not self.computed then
        self.computed = true
        self:compute()
    end
    local line = self.lines[row]
    if not line then
        line = { hidden = false, conceals = {} }
    end
    return line
end

---Cached row level implementation of vim.treesitter.get_captures_at_pos
---@private
function Highlights:compute()
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
function Highlights:tree(language, root)
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
            local row = Highlights.range(id, data, node)
            self:add(row, { hidden = true })
        end
        if data.conceal then
            local row, start_col, _, end_col = Highlights.range(id, data, node)
            self:add(row, {
                conceal = {
                    start_col,
                    end_col,
                    replacement = data.conceal,
                    blocks = 1,
                },
            })
        end
    end)
end

---@private
---@param id integer
---@param data vim.treesitter.query.TSMetadata
---@param node TSNode
---@return integer, integer, integer, integer
function Highlights.range(id, data, node)
    local range = (data[id] or {}).range or data.range or { node:range() }
    local offset = (data[id] or {}).offset or data.offset or { 0, 0, 0, 0 }
    return range[1] + tonumber(offset[1]),
        range[2] + tonumber(offset[2]),
        range[3] + tonumber(offset[3]),
        range[4] + tonumber(offset[4])
end

return Highlights
