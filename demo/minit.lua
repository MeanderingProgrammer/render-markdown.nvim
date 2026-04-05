-- general settings
vim.o.termguicolors = true
vim.o.cursorline = true

-- line settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.statuscolumn = '%s%=%{v:relnum?v:relnum:v:lnum} '
vim.o.wrap = false

-- mode is already in status line plugin
vim.o.showmode = false

vim.pack.add({
    'https://github.com/folke/tokyonight.nvim',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-mini/mini.nvim',
    'https://github.com/nvim-lualine/lualine.nvim',
})

vim.cmd.packadd('render-markdown.nvim')

---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup({ style = 'night' })
vim.cmd.colorscheme('tokyonight')

require('nvim-treesitter')
    .install({ 'html', 'latex', 'markdown', 'markdown_inline', 'yaml' })
    :wait()

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('Highlighter', {}),
    pattern = 'markdown',
    callback = function(args)
        vim.treesitter.start(args.buf)
    end,
})

local icons = require('mini.icons')
icons.setup({})
icons.mock_nvim_web_devicons()

-- selene: allow(mixed_table)
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

require('render-markdown').setup({})
