local compat = require('render-markdown.lib.compat')

---@class render.md.ts.Config
---@field file_types string[]
---@field injections table<string, render.md.injection.Config>
---@field patterns table<string, render.md.pattern.Config>

---@class render.md.Ts
---@field private config render.md.ts.Config
local M = {}

---@private
---@type boolean
M.initialized = false

---@private
---@type table<string, vim.treesitter.Query>
M.queries = {}

---called from state on setup
---@param config render.md.ts.Config
function M.setup(config)
    M.config = config
    for _, language in ipairs(M.config.file_types) do
        M.inject(language)
    end
end

---called from manager on buffer attach
function M.init()
    if M.initialized then
        return
    end
    M.initialized = true
    for _, language in ipairs(M.config.file_types) do
        M.disable(language)
    end
end

---@param language string
---@param query string
---@return vim.treesitter.Query
function M.parse(language, query)
    local result = M.queries[query]
    if not result then
        result = vim.treesitter.query.parse(language, query)
        M.queries[query] = result
    end
    return result
end

---@private
---@param language string
function M.inject(language)
    local injection = M.config.injections[language]
    if not injection or not injection.enabled then
        return
    end
    local query = ''
    if compat.has_11 then
        query = query .. ';; extends' .. '\n'
    else
        local files = vim.treesitter.query.get_files(language, 'injections')
        for _, file in ipairs(files) do
            local f = io.open(file, 'r')
            if f then
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
function M.disable(language)
    local pattern = M.config.patterns[language]
    if not pattern or not pattern.disable then
        return
    end
    if not compat.has_11 then
        return
    end
    local query = vim.treesitter.query.get(language, 'highlights')
    if not query then
        return
    end
    if not query.query.disable_pattern then
        compat.release('TSQuery missing disable_pattern API')
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
    if not directives then
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
