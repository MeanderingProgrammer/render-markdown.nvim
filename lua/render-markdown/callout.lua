local callout_to_key = {
    ['[!NOTE]'] = 'note',
    ['[!TIP]'] = 'tip',
    ['[!IMPORTANT]'] = 'important',
    ['[!WARNING]'] = 'warning',
    ['[!CAUTION]'] = 'caution',
}

local M = {}

---@param value string
---@return string?
M.get_key_exact = function(value)
    return callout_to_key[value]
end

---@param value string
---@return string?
M.get_key_contains = function(value)
    for callout, key in pairs(callout_to_key) do
        if value:find(callout, 1, true) then
            return key
        end
    end
    return nil
end

return M
