local initialized = false
if initialized then
    return
end
initialized = true

require('render-markdown').setup(vim.g.render_markdown_config)
require('render-markdown.core.colors').init()
require('render-markdown.core.command').init()
require('render-markdown.core.log').init()
require('render-markdown.core.manager').init()
