---@param path_name string
---@param plugin_name string?
local function source_plugin(path_name, plugin_name)
    local data_path = vim.fn.stdpath('data')
    assert(type(data_path) == 'string')
    local plugin_path = vim.fs.find(path_name, { path = data_path })
    vim.opt.rtp:prepend(unpack(plugin_path))
    if plugin_name ~= nil then
        vim.cmd.runtime('plugin/' .. plugin_name)
    end
end

---@param required_parsers string[]
local function ensure_installed(required_parsers)
    local installed_parsers = require('nvim-treesitter.info').installed_parsers()
    local to_install = vim.tbl_filter(function(parser)
        return not vim.tbl_contains(installed_parsers, parser)
    end, required_parsers)
    if #to_install > 0 then
        vim.cmd.TSInstallSync({ bang = true, args = to_install })
    end
end

vim.opt.rtp:prepend('.')
source_plugin('plenary.nvim', 'plenary.vim')
source_plugin('nvim-treesitter', 'nvim-treesitter.lua')
source_plugin('mini.nvim', nil)

-- https://github.com/ThePrimeagen/refactoring.nvim/blob/master/scripts/minimal.vim
ensure_installed({ 'markdown', 'markdown_inline', 'latex' })

---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup({
    highlight = { enable = true },
})
