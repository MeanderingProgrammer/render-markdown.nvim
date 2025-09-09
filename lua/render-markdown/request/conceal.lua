local compat = require('render-markdown.lib.compat')
local env = require('render-markdown.lib.env')
local interval = require('render-markdown.lib.interval')
local str = require('render-markdown.lib.str')

---@class render.md.request.conceal.Line
---@field hidden boolean
---@field sections render.md.request.conceal.Section[]

---@class render.md.request.conceal.Section
---@field col render.md.Range
---@field width integer
---@field character? string

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
---@param entry boolean|render.md.request.conceal.Section
function Conceal:add(row, entry)
    if not self:enabled() then
        return
    end
    if not self.lines[row] then
        self.lines[row] = { hidden = false, sections = {} }
    end
    local line = self.lines[row]
    if type(entry) == 'boolean' then
        line.hidden = entry
    else
        if entry.width > 0 and not Conceal.contains(line, entry) then
            line.sections[#line.sections + 1] = entry
        end
    end
end

---@private
---@param line render.md.request.conceal.Line
---@param entry render.md.request.conceal.Section
---@return boolean
function Conceal.contains(line, entry)
    for _, section in ipairs(line.sections) do
        if interval.contains(section.col, entry.col) then
            return true
        end
    end
    return false
end

---@param character? string
---@return integer
function Conceal:width(character)
    if self.level == 1 then
        -- each block is replaced with one character
        return 1
    elseif self.level == 2 then
        -- replacement character width is used
        return str.width(character)
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
    local col = { body.start_col, body.end_col } ---@type render.md.Range
    for _, section in ipairs(self:line(body).sections) do
        if interval.overlaps(section.col, col, true) then
            local width = section.width - self:width(section.character)
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
        line = { hidden = false, sections = {} }
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
            local text = vim.treesitter.get_node_text(node, self.buf)
            self:add(row, {
                col = { start_col, end_col },
                width = str.width(text),
                character = data.conceal,
            })
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
