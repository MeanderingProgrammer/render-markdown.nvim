local Base = require('render-markdown.render.base')
local List = require('render-markdown.lib.list')
local ts = require('render-markdown.integ.ts')

---@class render.md.quote.Data
---@field query vim.treesitter.Query
---@field level integer
---@field icon string
---@field highlight string
---@field repeat_linebreak? boolean

---@class render.md.render.Quote: render.md.Render
---@field private data render.md.quote.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@return boolean
function Render:setup()
    local config = self.config.quote
    if self.context:skip(config) then
        return false
    end
    local level = self.node:level_in_section('block_quote')
    local callout = self.context:get_callout(self.node.start_row)
    self.data = {
        query = ts.parse(
            'markdown',
            [[
                (block_quote_marker) @marker
                (block_continuation) @continuation
            ]]
        ),
        level = level,
        icon = callout ~= nil and callout.quote_icon
            or assert(List.cycle(config.icon, level)),
        highlight = callout ~= nil and callout.highlight
            or assert(List.cycle(config.highlight, level)),
        repeat_linebreak = config.repeat_linebreak or nil,
    }
    return true
end

function Render:render()
    self.context:query(self.node:get(), self.data.query, function(capture, node)
        if capture == 'marker' then
            -- marker nodes are a single '>' at the start of a block quote
            -- overlay the only range if it is at the current level
            if node:level_in_section('block_quote') == self.data.level then
                self:quote(node, 1)
            end
        elseif capture == 'continuation' then
            -- continuation nodes are a group of '>'s inside a block quote
            -- overlay the range of the one at the current level if it exists
            self:quote(node, self.data.level)
        else
            error('Unhandled quote capture: ' .. capture)
        end
    end)
end

---@private
---@param node render.md.Node
---@param index integer
function Render:quote(node, index)
    local range = node:find('>')[index]
    if range == nil then
        return
    end
    self.marks:add('quote', range[1], range[2], {
        end_row = range[3],
        end_col = range[4],
        virt_text = { { self.data.icon, self.data.highlight } },
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = self.data.repeat_linebreak,
    })
end

return Render
