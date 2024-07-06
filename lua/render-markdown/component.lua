local state = require('render-markdown.state')

---@class render.md.Component
---@field text string
---@field highlight string

---@class render.md.CalloutInfo
---@field text string
---@field key string

---@type render.md.CalloutInfo[]
local callouts = {
    { text = '[!NOTE]', key = 'note' },
    { text = '[!TIP]', key = 'tip' },
    { text = '[!IMPORTANT]', key = 'important' },
    { text = '[!WARNING]', key = 'warning' },
    { text = '[!CAUTION]', key = 'caution' },
}

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
    for _, callout in ipairs(callouts) do
        if matches(callout.text) then
            return {
                text = state.config.callout[callout.key],
                highlight = state.config.highlights.callout[callout.key],
            }
        end
    end
    for _, callout in pairs(state.config.callout.custom) do
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
