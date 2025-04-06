local Compat = require('render-markdown.lib.compat')

---@class render.md.integ.TreeSitter
---@field private initialized boolean
---@field private queries table<string, vim.treesitter.Query>
local M = {
    initialized = false,
    queries = {},
}

---Should only be called from manager on initial buffer attach
function M.setup()
    if M.initialized then
        return
    end
    M.initialized = true
    local state = require('render-markdown.state')
    for _, language in ipairs(state.file_types) do
        M.disable(language, state.patterns[language])
    end
end

---@param language string
---@param query string
---@return vim.treesitter.Query
function M.parse(language, query)
    local result = M.queries[query]
    if result == nil then
        result = vim.treesitter.query.parse(language, query)
        M.queries[query] = result
    end
    return result
end

---@param language string
---@param injection? render.md.injection.Config
function M.inject(language, injection)
    if injection == nil or not injection.enabled then
        return
    end
    local query = ''
    if Compat.has_11 then
        query = query .. ';; extends' .. '\n'
    else
        local files = vim.treesitter.query.get_files(language, 'injections')
        for _, file in ipairs(files) do
            local f = io.open(file, 'r')
            if f ~= nil then
                query = query .. f:read('*all') .. '\n'
                f:close()
            end
        end
    end
    query = query .. injection.query
    pcall(vim.treesitter.query.set, language, 'injections', query)
end

---@private
---@param language string
---@param pattern? render.md.pattern.Config
function M.disable(language, pattern)
    if pattern == nil or not pattern.disable then
        return
    end
    if not Compat.has_11 then
        return
    end
    local query = vim.treesitter.query.get(language, 'highlights')
    if query == nil then
        return
    end
    if query.query.disable_pattern == nil then
        Compat.release_notification('TSQuery missing disable_pattern API')
        return
    end
    local query_directives = query.info.patterns
    for _, directive in ipairs(pattern.directives) do
        local query_directive = query_directives[directive.id]
        if M.has_directive(directive.name, query_directive) then
            query.query:disable_pattern(directive.id)
        end
    end
end

---@private
---@param name string
---@param directives? (string|integer)[][]
---@return boolean
function M.has_directive(name, directives)
    if directives == nil then
        return false
    end
    for _, directive in ipairs(directives) do
        if directive[1] == 'set!' and directive[2] == name then
            return true
        end
    end
    return false
end

return M
