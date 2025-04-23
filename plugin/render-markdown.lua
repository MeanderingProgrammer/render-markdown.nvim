local initialized = false
if initialized then
    return
end
initialized = true

require('render-markdown').setup()
require('render-markdown.colors').init()
require('render-markdown.command').init()
require('render-markdown.manager').init()
require('render-markdown.core.log').init()
