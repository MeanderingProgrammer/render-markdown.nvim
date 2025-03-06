---@param name string
---@return string
local function get_path(name)
    local data_path = vim.fn.stdpath('data')
    assert(type(data_path) == 'string')
    local plugin_path = vim.fs.find(name, { path = data_path })
    assert(#plugin_path == 1)
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

-- Settings
vim.opt.lines = 40
vim.opt.columns = 80
vim.opt.number = true

-- Source dependencies first
vim.opt.rtp:prepend(get_path('nvim-treesitter'))
vim.cmd.runtime('plugin/nvim-treesitter.lua')
vim.opt.rtp:prepend(get_path('mini.nvim'))

-- Now we can safely source this plugin
vim.opt.rtp:prepend('.')
vim.cmd.runtime('plugin/render-markdown.lua')

-- Used for unit testing, not an actual dependency of this plugin
vim.opt.rtp:prepend(get_path('plenary.nvim'))
vim.cmd.runtime('plugin/plenary.vim')

ensure_installed({ 'html', 'latex', 'markdown', 'markdown_inline' })

---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup({
    highlight = { enable = true },
})
