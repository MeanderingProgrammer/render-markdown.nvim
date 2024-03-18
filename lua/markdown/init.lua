local state = require('markdown.state')

local M = {}

---@class UserHighlights
---@field public heading? string
---@field public code? string

---@class UserConfig
---@field public query? Query
---@field public bullets? string[]
---@field public highlights? Highlights

---@param opts UserConfig|nil
function M.setup(opts)
    ---@type Config
    local default_config = {
        query = vim.treesitter.query.parse(
            'markdown',
            [[
                (atx_heading [
                    (atx_h1_marker)
                    (atx_h2_marker)
                    (atx_h3_marker)
                    (atx_h4_marker)
                    (atx_h5_marker)
                    (atx_h6_marker)
                ] @heading)

                (fenced_code_block) @code
            ]]
        ),
        bullets = { '◉', '○', '✸', '✿' },
        highlights = {
            heading = '@comment.hint',
            code = 'ColorColumn',
        },
    }
    state.config = vim.tbl_deep_extend('force', default_config, opts or {})

    vim.api.nvim_create_autocmd({
        'FileChangedShellPost',
        'InsertLeave',
        'Syntax',
        'TextChanged',
        'WinResized',
    }, {
        group = vim.api.nvim_create_augroup('Markdown', { clear = true }),
        callback = function()
            vim.schedule(M.refresh)
        end,
    })
end

M.namespace = vim.api.nvim_create_namespace('markdown.nvim')

M.refresh = function()
    if vim.bo.filetype ~= 'markdown' then
        return
    end

    -- Remove existing highlights / virtual text
    vim.api.nvim_buf_clear_namespace(0, M.namespace, 0, -1)

    local parser = vim.treesitter.get_parser(0, 'markdown')
    local root = parser:parse()[1]:root()

    local highlights = state.config.highlights

    ---@diagnostic disable-next-line: missing-parameter
    for id, node in state.config.query:iter_captures(root, 0) do
        local capture = state.config.query.captures[id]
        local start_row, _, end_row, _ = node:range()

        if capture == 'heading' then
            local level = #vim.treesitter.get_node_text(node, 0)
            local bullet = state.config.bullets[((level - 1) % #state.config.bullets) + 1]
            vim.api.nvim_buf_set_extmark(0, M.namespace, start_row, 0, {
                end_row = end_row + 1,
                end_col = 0,
                hl_group = highlights.heading,
                -- This is done to exactly cover over the heading hashtags
                virt_text = { { string.rep(' ', level - 1) .. bullet, highlights.heading } },
                virt_text_pos = 'overlay',
                hl_eol = true,
            })
        elseif capture == 'code' then
            vim.api.nvim_buf_set_extmark(0, M.namespace, start_row, 0, {
                end_row = end_row,
                end_col = 0,
                hl_group = highlights.code,
                hl_eol = true,
            })
        end
    end
end

return M
