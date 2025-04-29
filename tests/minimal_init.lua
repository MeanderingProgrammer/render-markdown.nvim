---@param name string
---@return string
local function get_path(name)
    local data_path = vim.fn.stdpath('data')
    local plugin_path = vim.fs.find(name, { path = data_path })
    assert(#plugin_path == 1, 'plugin must have one path')
    return plugin_path[1]
end

---https://github.com/ThePrimeagen/refactoring.nvim/blob/master/scripts/minimal.vim
---@param parsers string[]
local function ensure_installed(parsers)
    local installed = require('nvim-treesitter.info').installed_parsers()
    local missing = vim.tbl_filter(function(parser)
        return not vim.tbl_contains(installed, parser)
    end, parsers)
    if #missing > 0 then
        vim.cmd.TSInstallSync({ bang = true, args = missing })
    end
end

-- settings
vim.opt.lines = 40
vim.opt.columns = 80

-- source dependencies first
vim.opt.rtp:prepend(get_path('nvim-treesitter'))
vim.cmd.runtime('plugin/nvim-treesitter.lua')
vim.opt.rtp:prepend(get_path('mini.nvim'))

-- source this plugin
vim.opt.rtp:prepend('.')
vim.cmd.runtime('plugin/render-markdown.lua')

-- used for unit testing
vim.opt.rtp:prepend(get_path('plenary.nvim'))
vim.cmd.runtime('plugin/plenary.vim')

ensure_installed({ 'html', 'latex', 'markdown', 'markdown_inline' })

---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup({
    highlight = { enable = true },
})

require('mini.icons').setup({})
