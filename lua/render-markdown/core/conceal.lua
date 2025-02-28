local Str = require('render-markdown.lib.str')
local util = require('render-markdown.core.util')

---@class render.md.conceal.Section
---@field start_col integer
---@field end_col integer
---@field width integer
---@field character? string

---@class render.md.conceal.Line
---@field hidden boolean
---@field sections render.md.conceal.Section[]

---@class render.md.Conceal
---@field private buf integer
---@field private level integer
---@field private computed boolean
---@field private lines table<integer, render.md.conceal.Line>
local Conceal = {}
Conceal.__index = Conceal

---@param buf integer
---@param level integer
---@return render.md.Conceal
function Conceal.new(buf, level)
    local self = setmetatable({}, Conceal)
    self.buf = buf
    self.level = level
    self.computed = false
    self.lines = {}
    return self
end

---@return boolean
function Conceal:enabled()
    return self.level > 0
end

---@param row integer
---@param entry boolean|render.md.conceal.Section
function Conceal:add(row, entry)
    if not self:enabled() then
        return
    end
    if self.lines[row] == nil then
        self.lines[row] = { hidden = false, sections = {} }
    end
    local line = self.lines[row]
    if type(entry) == 'boolean' then
        line.hidden = entry
    else
        if entry.width <= 0 then
            return
        end
        -- If the section is covered by an existing one don't add it
        for _, section in ipairs(line.sections) do
            if section.start_col <= entry.start_col and section.end_col >= entry.end_col then
                return
            end
        end
        table.insert(line.sections, entry)
    end
end

---@param width integer
---@param character? string
---@return integer
function Conceal:adjust(width, character)
    if self.level == 1 then
        -- each block is replaced with one character
        return width - 1
    elseif self.level == 2 then
        -- replacement character width is used
        return width - Str.width(character)
    else
        return width
    end
end

---@param context render.md.Context
---@param node render.md.Node
---@return boolean
function Conceal:hidden(context, node)
    -- conceal lines metadata require neovim >= 0.11.0 to function
    return util.has_11 and self:line(context, node).hidden
end

---@param context render.md.Context
---@param node render.md.Node
---@return integer
function Conceal:get(context, node)
    local result = 0
    for _, section in ipairs(self:line(context, node).sections) do
        if node.start_col < section.end_col and node.end_col > section.start_col then
            local amount = self:adjust(section.width, section.character)
            result = result + amount
        end
    end
    return result
end

---@private
---@param context render.md.Context
---@param node render.md.Node
function Conceal:line(context, node)
    if not self.computed then
        self:compute(context)
        self.computed = true
    end
    local line = self.lines[node.start_row]
    if line == nil then
        line = { hidden = false, sections = {} }
    end
    return line
end

---Cached row level implementation of vim.treesitter.get_captures_at_pos
---@private
---@param context render.md.Context
function Conceal:compute(context)
    if not self:enabled() then
        return
    end
    if vim.treesitter.highlighter.active[self.buf] == nil then
        return
    end
    local parser = vim.treesitter.get_parser(self.buf)
    if parser == nil then
        return
    end
    context:parse(parser)
    parser:for_each_tree(function(tree, language_tree)
        self:compute_tree(context, language_tree:lang(), tree:root())
    end)
end

---@private
---@param context render.md.Context
---@param language string
---@param root TSNode
function Conceal:compute_tree(context, language, root)
    if not context:overlaps_node(root) then
        return
    end
    if not vim.tbl_contains({ 'markdown', 'markdown_inline' }, language) then
        return
    end
    local query = vim.treesitter.query.get(language, 'highlights')
    if query == nil then
        return
    end
    context:for_each(function(range)
        for id, node, metadata in query:iter_captures(root, self.buf, range.top, range.bottom) do
            if metadata.conceal_lines ~= nil then
                local node_range = self:node_range(id, node, metadata)
                local row = unpack(node_range)
                self:add(row, true)
            end
            if metadata.conceal ~= nil then
                local node_range = self:node_range(id, node, metadata)
                local row, start_col, _, end_col = unpack(node_range)
                self:add(row, {
                    start_col = start_col,
                    end_col = end_col,
                    width = Str.width(vim.treesitter.get_node_text(node, self.buf)),
                    character = metadata.conceal,
                })
            end
        end
    end)
end

---@private
---@param id integer
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@return Range
function Conceal:node_range(id, node, metadata)
    local range = metadata.range
    if range ~= nil then
        return range
    end
    range = metadata[id] ~= nil and metadata[id].range or nil
    if range ~= nil then
        return range
    end
    return { node:range() }
end

return Conceal
