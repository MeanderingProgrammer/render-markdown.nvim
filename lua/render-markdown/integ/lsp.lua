local source = require('render-markdown.integ.source')

---@class render.md.integ.Lsp
local M = {}

---called from state on attach
function M.init()
    local name = 'render-markdown'
    vim.lsp.start({ name = name, cmd = M.server }, {
        bufnr = 0,
        reuse_client = function(client, config)
            return client.name == config.name
        end,
    })
end

---@private
---@param dispatchers vim.lsp.rpc.Dispatchers
---@return vim.lsp.rpc.PublicClient
function M.server(dispatchers)
    local id = 0
    local closing = false

    ---@type vim.lsp.rpc.PublicClient
    return {
        request = function(method, params, callback)
            if method == 'initialize' then
                callback(nil, {
                    capabilities = {
                        completionProvider = {
                            triggerCharacters = source.trigger_characters(),
                        },
                    },
                })
            elseif method == 'textDocument/completion' then
                callback(nil, M.completions(params))
            elseif method == 'shutdown' then
                callback(nil, nil)
            end
            id = id + 1
            return true, id
        end,
        notify = function(method)
            if method == 'exit' then
                -- code 0 (success), signal 15 (SIGTERM)
                dispatchers.on_exit(0, 15)
            end
            return true
        end,
        is_closing = function()
            return closing
        end,
        terminate = function()
            closing = true
        end,
    }
end

---@private
---@param params lsp.CompletionParams
---@return lsp.CompletionList?
function M.completions(params)
    -- lsp position: (0,0)-indexed
    local cursor = params.position
    local items = source.items(0, cursor.line, cursor.character)
    if not items then
        return nil
    end
    ---@type lsp.CompletionList
    return {
        isIncomplete = false,
        items = items,
    }
end

return M
