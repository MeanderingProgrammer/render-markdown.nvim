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
    M.patch_styles()
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
---@type [string, string][]
M.styles = {
    { 'emphasis', 'markup.italic' },
    { 'strong_emphasis', 'markup.strong' },
    { 'strikethrough', 'markup.strikethrough' },
}

---inline styles are allowed to span lines, which mangles unrelated text such as
---shell prompts containing '~', limit upstream highlights & conceals to one line
---@private
function M.patch_styles()
    local query = ''
    local files =
        vim.treesitter.query.get_files('markdown_inline', 'highlights')
    for _, file in ipairs(files) do
        local f = assert(io.open(file, 'r'))
        query = query .. f:read('*a') .. '\n'
        f:close()
    end

    ---@param from string
    ---@param to string
    ---@return boolean
    local function replace(from, to)
        local start, stop = query:find(from, 1, true)
        if not start then
            return false
        end
        query = query:sub(1, start - 1) .. to .. query:sub(stop + 1)
        return true
    end

    -- long strings keep '\n' as an escape for the query parser to handle
    local highlight = [[
((%s) @%s
  (#not-lua-match? @%s "\n"))]]
    local conceal = [[

((%s (emphasis_delimiter) @conceal) @_style
  (#not-lua-match? @_style "\n")
  (#set! @conceal conceal ""))
]]

    -- delimiters are concealed for every style at once, drop them from that
    -- pattern and conceal them per style, gated on the style being one line
    local patched = replace('(emphasis_delimiter)', '')
    for _, style in ipairs(M.styles) do
        local node, capture = style[1], style[2]
        local from = ('(%s) @%s'):format(node, capture)
        local to = highlight:format(node, capture, capture)
        patched = replace(from, to) and patched
        query = query .. conceal:format(node)
    end

    -- all or nothing, a partial patch conceals delimiters that no longer exist
    if patched then
        pcall(vim.treesitter.query.set, 'markdown_inline', 'highlights', query)
    end
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
