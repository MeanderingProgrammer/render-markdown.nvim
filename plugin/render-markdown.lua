if vim.g.loaded_render_markdown then
    return
end
vim.g.loaded_render_markdown = true

require('render-markdown').setup()
require('render-markdown.colors').setup()
require('render-markdown.command').setup()
require('render-markdown.manager').setup()
