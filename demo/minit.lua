-- General settings
vim.opt.termguicolors = true
vim.opt.cursorline = true

-- Line settings
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.statuscolumn = '%s%=%{v:relnum?v:relnum:v:lnum} '

-- Mode is already in status line plugin
vim.opt.showmode = false

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
assert(vim.uv.fs_stat(lazypath))
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    dev = { path = '~/dev/repos/personal' },
    spec = {
        {
            'folke/tokyonight.nvim',
            config = function()
                ---@diagnostic disable-next-line: missing-fields
                require('tokyonight').setup({ style = 'night' })
                vim.cmd.colorscheme('tokyonight')
            end,
        },
        {
            'nvim-treesitter/nvim-treesitter',
            build = ':TSUpdate',
            config = function()
                ---@diagnostic disable-next-line: missing-fields
                require('nvim-treesitter.configs').setup({
                    ensure_installed = { 'markdown', 'markdown_inline', 'latex' },
                    highlight = { enable = true },
                })
            end,
        },
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = function()
                require('lualine').setup({
                    sections = {
                        lualine_a = { 'mode' },
                        lualine_b = { { 'filename', path = 0 } },
                        lualine_c = {},
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = { 'location' },
                    },
                })
            end,
        },
        {
            'MeanderingProgrammer/render-markdown.nvim',
            dev = true,
            dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
            config = function()
                require('render-markdown').setup({})
            end,
        },
    },
})
