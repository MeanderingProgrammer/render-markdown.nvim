local state = require('render-markdown.state')

---@class render.md.Component
---@field text string
---@field highlight string

local M = {}

---@param value string
---@param comparison 'exact'|'contains'
---@return render.md.Component?
M.callout = function(value, comparison)
    ---@param text string
    ---@return boolean
    local function matches(text)
        if comparison == 'exact' then
            return value == text
        elseif comparison == 'contains' then
            return value:find(text, 1, true) ~= nil
        else
            error(string.format('Unhandled comparison: %s', comparison))
        end
    end
    for _, callout in pairs(state.config.callout) do
        if matches(callout.raw) then
            return { text = callout.rendered, highlight = callout.highlight }
        end
    end
    return nil
end

---@param value string
---@param comparison 'exact'|'starts'
---@return render.md.Component?
M.checkbox = function(value, comparison)
    ---@param text string
    ---@return boolean
    local function matches(text)
        if comparison == 'exact' then
            return value == text
        elseif comparison == 'starts' then
            return vim.startswith(value, text)
        else
            error(string.format('Unhandled comparison: %s', comparison))
        end
    end
    for _, checkbox in pairs(state.config.checkbox.custom) do
        if matches(checkbox.raw) then
            return { text = checkbox.rendered, highlight = checkbox.highlight }
        end
    end
    return nil
end

return M
