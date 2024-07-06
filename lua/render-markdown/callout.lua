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
---@return string?
M.get_key_exact = function(value)
    for _, callout in ipairs(callouts) do
        if value == callout.text then
            return callout.key
        end
    end
    return nil
end

---@param value string
---@return string?
M.get_key_contains = function(value)
    for _, callout in ipairs(callouts) do
        if value:find(callout.text, 1, true) then
            return callout.key
        end
    end
    return nil
end

return M
