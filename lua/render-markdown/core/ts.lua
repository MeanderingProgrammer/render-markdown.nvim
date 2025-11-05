local compat = require('render-markdown.lib.compat')
local state = require('render-markdown.state')

---@class render.md.Ts
local M = {}

---@private
---@type boolean
M.initialized = false

---@private
---@type table<string, vim.treesitter.Query>
M.queries = {}

---called from state on setup
function M.setup()
    for _, language in ipairs(state.file_types) do
        M.inject(language)
    end
end

---called from state on attach
function M.init()
    if M.initialized then
        return
    end
    M.initialized = true
    for _, language in ipairs(state.file_types) do
        M.disable(language)
    end
    if state.restart_highlighter then
        vim.treesitter.stop()
        vim.treesitter.start()
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
    local injection = state.injections[language]
    if not injection or not injection.enabled then
        return
    end
    local query = ''
    if compat.has_11 then
        query = query .. ';; extends' .. '\n'
    else
        local files = vim.treesitter.query.get_files(language, 'injections')
        for _, file in ipairs(files) do
            local f = assert(io.open(file, 'r'))
            local body = f:read('*a') --[[@as string]]
            f:close()
            query = query .. body .. '\n'
        end
    end
    query = query .. injection.query
    pcall(vim.treesitter.query.set, language, 'injections', query)
end

---@private
---@param language string
function M.disable(language)
    local pattern = state.patterns[language]
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
