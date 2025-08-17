local Base = require('render-markdown.render.base')
local str = require('render-markdown.lib.str')

---@class render.md.render.common.Wiki: render.md.Render
---@field private config render.md.link.wiki.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    local config = self.context.config.link
    if self.context:skip(config) then
        return false
    end
    self.config = config.wiki
    return true
end

---@protected
function Render:run()
    local _, _, pre, text, post = self.node.text:find('^(.-%[+)(.-)(%]+.-)$')
    if not pre or not text or not post then
        return -- not inside square brackets
    end
    if #pre ~= #post then
        return -- pre and post are not balanced
    end

    local row = self.node.start_row
    local start_col = self.node.start_col + #pre
    local end_col = self.node.end_col - #pre
    local destination, alias = unpack(str.split(text, '|', true))

    -- hide opening & closing brackets
    self:hide(start_col - 2, 2)
    self:hide(end_col, 2)

    ---@type render.md.mark.Text
    local icon = { self.config.icon, self.config.highlight }
    self.context.config:set_link_text(destination, icon)
    local body = self.config.body({
        buf = self.context.buf,
        row = row,
        start_col = start_col - 2,
        end_col = end_col + 2,
        destination = destination,
        alias = alias,
    })
    if not body then
        -- add icon
        self.marks:add('link', row, start_col, {
            hl_mode = 'combine',
            virt_text = { icon },
            virt_text_pos = 'inline',
        })
        -- apply scope highlight
        local highlight = self.config.scope_highlight
        if highlight then
            self.marks:add('link', row, start_col, {
                end_col = end_col,
                hl_group = highlight,
            })
        end
        -- hide destination if there is an alias
        if alias then
            self:hide(start_col, #destination + 1)
        end
    else
        if type(body) == 'string' then
            icon[1] = icon[1] .. body
        else
            icon[1] = icon[1] .. body[1]
            icon[2] = body[2]
        end
        -- inline icon & body, hide original text
        self.marks:add('link', row, start_col, {
            end_col = end_col,
            hl_mode = 'combine',
            virt_text = { icon },
            virt_text_pos = 'inline',
            conceal = '',
        })
    end
end

---@private
---@param col integer
---@param length integer
function Render:hide(col, length)
    self.marks:add(true, self.node.start_row, col, {
        end_col = col + length,
        conceal = '',
    })
end

return Render
