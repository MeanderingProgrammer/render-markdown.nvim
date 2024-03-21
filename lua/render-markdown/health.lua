---@param name string
local function parser_installed(name)
    local ok = pcall(vim.treesitter.query.parse, name, '')
    if ok then
        vim.health.ok(name .. ' parser installed')
    else
        vim.health.error(name .. ' parser not found')
    end
end

local M = {}

function M.check()
    vim.health.start('Checking required treesitter parsers')
    parser_installed('markdown')
end

return M
