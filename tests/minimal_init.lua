---@param path_name string
local function source_plugin(path_name)
    local data_path = vim.fn.stdpath('data')
    assert(type(data_path) == 'string')
    local plugin_path = vim.fs.find(path_name, { path = data_path })
    vim.opt.rtp:prepend(unpack(plugin_path))
end

---@param plugin_name string
local function add_runtime(plugin_name)
    vim.cmd.runtime('plugin/' .. plugin_name)
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

-- Settings
vim.opt.lines = 40
vim.opt.columns = 80
vim.opt.number = true

-- Source dependencies first
source_plugin('nvim-treesitter')
add_runtime('nvim-treesitter.lua')
source_plugin('mini.nvim')
-- Now we can safely source this plugin
vim.opt.rtp:prepend('.')
add_runtime('render-markdown.lua')
-- Used for unit testing, not an actual dependency of this plugin
source_plugin('plenary.nvim')
add_runtime('plenary.vim')

-- https://github.com/ThePrimeagen/refactoring.nvim/blob/master/scripts/minimal.vim
ensure_installed({ 'markdown', 'markdown_inline', 'latex' })

---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup({
    highlight = { enable = true },
})
