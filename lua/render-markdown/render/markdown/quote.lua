local Base = require('render-markdown.render.base')
local list = require('render-markdown.lib.list')
local str = require('render-markdown.lib.str')
local ts = require('render-markdown.core.ts')

---@class render.md.quote.Data
---@field callout? render.md.request.callout.Value
---@field level integer
---@field icon string
---@field highlight string
---@field repeat_linebreak? boolean

---@class render.md.render.Quote: render.md.Render
---@field private data render.md.quote.Data
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    local config = self.context.config.quote
    if self.context:skip(config) then
        return false
    end
    local callout = self.context.callout:get(self.node)
    local level = self.node:level_in_section('block_quote')
    local icon = callout and callout.config.quote_icon or config.icon
    local highlight = callout and callout.config.highlight or config.highlight
    self.data = {
        callout = callout,
        level = level,
        icon = assert(list.cycle(icon, level)),
        highlight = assert(list.cycle(highlight, level)),
        repeat_linebreak = config.repeat_linebreak or nil,
    }
    return true
end

---@protected
function Render:run()
    self:callout()
    self:markers()
end

---@private
function Render:callout()
    local callout = self.data.callout
    if not callout then
        return
    end
    local node = callout.node
    local config = callout.config
    local title = Render.title(node, config)
    self.marks:over('callout', node, {
        virt_text = { { title or config.rendered, config.highlight } },
        virt_text_pos = 'overlay',
        conceal = title and '' or nil,
    })
end

---@private
---@param node render.md.Node
---@param config render.md.callout.Config
---@return string?
function Render.title(node, config)
    -- https://help.obsidian.md/Editing+and+formatting/Callouts#Change+the+title
    local content = node:parent('inline')
    if content then
        local line = str.split(content.text, '\n', true)[1]
        local prefix = config.raw:lower()
        if #line > #prefix and vim.startswith(line:lower(), prefix) then
            local icon = str.split(config.rendered, ' ', true)[1]
            local title = vim.trim(line:sub(#prefix + 1))
            return icon .. ' ' .. title
        end
    end
    return nil
end

---@private
function Render:markers()
    local query = ts.parse(
        'markdown',
        [[
            (block_quote_marker) @marker
            (block_continuation) @continuation
        ]]
    )
    self.context.view:nodes(self.node:get(), query, function(capture, node)
        if capture == 'marker' then
            -- marker nodes are a single '>' at the start of a block quote
            -- overlay the only range if it is at the current level
            if node:level_in_section('block_quote') == self.data.level then
                self:marker(node, 1)
            end
        elseif capture == 'continuation' then
            -- continuation nodes are a group of '>'s inside a block quote
            -- overlay the range of the one at the current level if it exists
            self:marker(node, self.data.level)
        else
            error('unhandled quote capture: ' .. capture)
        end
    end)
end

---@private
---@param node render.md.Node
---@param index integer
function Render:marker(node, index)
    local range = node:find('>')[index]
    if not range then
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
