---@param name string
---@return string
local function get_path(name)
    local paths = vim.fs.find(name, { path = vim.fn.stdpath('data') })
    assert(#paths == 1, 'plugin must have one path')
    return paths[1]
end

-- settings
vim.o.columns = 80
vim.o.lines = 40
vim.o.tabstop = 4
vim.o.wrap = false

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

require('mini.icons').setup({})
