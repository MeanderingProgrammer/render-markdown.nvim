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

-- selene: allow(mixed_table)
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
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-mini/mini.nvim' },
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
            'nvim-treesitter/nvim-treesitter',
            branch = 'main',
            build = ':TSUpdate',
            config = function()
                require('nvim-treesitter')
                    .install({ 'html', 'latex', 'markdown', 'markdown_inline' })
                    :wait()

                vim.api.nvim_create_autocmd('FileType', {
                    group = vim.api.nvim_create_augroup('Highlighter', {}),
                    pattern = 'markdown',
                    callback = function(args)
                        vim.treesitter.start(args.buf)
                    end,
                })
            end,
        },
        {
            'nvim-mini/mini.nvim',
            config = function()
                local icons = require('mini.icons')
                icons.setup({})
                icons.mock_nvim_web_devicons()
            end,
        },
        {
            'MeanderingProgrammer/render-markdown.nvim',
            dev = true,
            dependencies = {
                'nvim-treesitter/nvim-treesitter',
                'nvim-mini/mini.nvim',
            },
            config = function()
                require('render-markdown').setup({})
            end,
        },
    },
})
