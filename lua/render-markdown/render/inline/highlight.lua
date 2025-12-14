local Base = require('render-markdown.render.base')

---@class render.md.render.inline.Highlight: render.md.Render
---@field private config render.md.inline.highlight.Config
local Render = setmetatable({}, Base)
Render.__index = Render

---@protected
---@return boolean
function Render:setup()
    self.config = self.context.config.inline_highlight
    if not self.config.enabled then
        return false
    end
    return true
end

---@protected
function Render:run()
    for _, range in ipairs(self.node:find('==[^=]+==')) do
        local top_level = self:top_level(range[1], range[2])
            and self:top_level(range[3], range[4])
        if top_level then
            -- hide first 2 equal signs
            self:hide(range[1], range[2], range[2] + 2)
            -- hide last 2 equal signs
            self:hide(range[3], range[4] - 2, range[4])

            local custom = self:custom(range, { 0, 2, 0, -2 })
            local highlight = self.config.highlight
            if custom then
                -- hide custom prefix
                self:hide(range[1], range[2] + 2, range[2] + 2 + #custom.prefix)
                highlight = custom.highlight
            end

            -- highlight contents
            self.marks:add(self.config, false, range[1], range[2], {
                end_row = range[3],
                end_col = range[4],
                hl_group = highlight,
            })
        end
    end
end

---@private
---@param row integer
---@param col integer
---@return boolean
function Render:top_level(row, col)
    local node = vim.treesitter.get_node({
        bufnr = self.context.buf,
        pos = { row, col },
        ignore_injections = false,
    })
    return node and node:type() == 'inline' or false
end

---@private
---@param row integer
---@param start_col integer
---@param end_col integer
function Render:hide(row, start_col, end_col)
    self.marks:add(self.config, true, row, start_col, {
        end_col = end_col,
        conceal = '',
    })
end

---@private
---@param range Range4
---@param offset Range4
---@return render.md.inline.highlight.custom.Config?
function Render:custom(range, offset)
    local lines = vim.api.nvim_buf_get_text(
        self.context.buf,
        range[1] + offset[1],
        range[2] + offset[2],
        range[3] + offset[3],
        range[4] + offset[4],
        {}
    )
    local text = table.concat(lines, '\n')
    for _, custom in pairs(self.config.custom) do
        if vim.startswith(text, custom.prefix) then
            return custom
        end
    end
    return nil
end

return Render
