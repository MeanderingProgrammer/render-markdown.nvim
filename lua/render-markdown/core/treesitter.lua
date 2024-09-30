---@type table<string, vim.treesitter.Query>
local queries = {}

---@class render.md.TreeSitter
local M = {}

---@param language string
---@param query string
---@return vim.treesitter.Query
function M.parse(language, query)
    local result = queries[query]
    if result == nil then
        result = vim.treesitter.query.parse(language, query)
        queries[query] = result
    end
    return result
end

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
