---@class render.md.TreeSitter
local M = {}

---@param language string
---@param injection render.md.Injection?
function M.inject(language, injection)
    if injection == nil or not injection.enabled then
        return
    end

    local query = ''
    local files = vim.treesitter.query.get_files(language, 'injections')
    for _, file in ipairs(files) do
        local f = io.open(file, 'r')
        if f ~= nil then
            query = query .. f:read('*all') .. '\n'
            f:close()
        end
    end
    query = query .. injection.query
    pcall(vim.treesitter.query.set, language, 'injections', query)
end

return M
