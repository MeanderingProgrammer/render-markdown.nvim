local Base = require('render-markdown.render.base')
local str = require('render-markdown.lib.str')

---@class render.md.render.common.Wiki: render.md.Render
---@field private config render.md.link.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.link
    if not self.config.enabled then
        return false
    end
    return true
end

---@protected
function Render:run()
    local config = self.config.wiki
    if not config.enabled then
        return
    end

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
    local icon = { config.icon, config.highlight }
    self.context.config:set_link_text(destination, icon)
    local body = config.body({
        buf = self.context.buf,
        row = row,
        start_col = start_col - 2,
        end_col = end_col + 2,
        destination = destination,
        alias = alias,
    })
    if not body then
        -- add icon
        self.marks:add(self.config, 'link', row, start_col, {
            priority = 9000,
            hl_mode = 'combine',
            virt_text = { icon },
            virt_text_pos = 'inline',
        })
        -- apply scope highlight
        local highlight = config.scope_highlight
        if highlight then
            self.marks:add(self.config, 'link', row, start_col, {
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
        self.marks:add(self.config, 'link', row, start_col, {
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
    self.marks:add(self.config, true, self.node.start_row, col, {
        end_col = col + length,
        conceal = '',
    })
end

return Render
