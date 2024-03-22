local list = require('render-markdown.list')
local state = require('render-markdown.state')

local M = {}

---@class UserTableHighlights
---@field public head? string
---@field public row? string

---@class UserHeadingHighlights
---@field public backgrounds? string[]
---@field public foregrounds? string[]

---@class UserHighlights
---@field public heading? UserHeadingHighlights
---@field public code? string
---@field public bullet? string
---@field public table? UserTableHighlights

---@class UserConfig
---@field public query? Query
---@field public file_types? string[]
---@field public render_modes? string[]
---@field public headings? string[]
---@field public bullet? string
---@field public highlights? UserHighlights

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

                (list_item) @item

                (pipe_table_header) @table_head
                (pipe_table_delimiter_row) @table_delim
                (pipe_table_row) @table_row
            ]]
        ),
        file_types = { 'markdown' },
        render_modes = { 'n', 'c' },
        headings = { '󰲡', '󰲣', '󰲥', '󰲧', '󰲩', '󰲫' },
        bullet = '○',
        highlights = {
            heading = {
                backgrounds = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
                foregrounds = {
                    'markdownH1',
                    'markdownH2',
                    'markdownH3',
                    'markdownH4',
                    'markdownH5',
                    'markdownH6',
                },
            },
            code = 'ColorColumn',
            bullet = 'Normal',
            table = {
                head = '@markup.heading',
                row = 'Normal',
            },
        },
    }
    state.config = vim.tbl_deep_extend('force', default_config, opts or {})

    -- Call immediately to re-render on LazyReload
    M.refresh()

    vim.api.nvim_create_autocmd({
        'FileChangedShellPost',
        'ModeChanged',
        'Syntax',
        'TextChanged',
        'WinResized',
    }, {
        group = vim.api.nvim_create_augroup('RenderMarkdown', { clear = true }),
        callback = function()
            vim.schedule(M.refresh)
        end,
    })
end

M.namespace = vim.api.nvim_create_namespace('render-markdown.nvim')

M.refresh = function()
    if not vim.tbl_contains(state.config.file_types, vim.bo.filetype) then
        return
    end

    -- Remove existing highlights / virtual text
    vim.api.nvim_buf_clear_namespace(0, M.namespace, 0, -1)

    if not vim.tbl_contains(state.config.render_modes, vim.fn.mode()) then
        return
    end

    local highlights = state.config.highlights

    local root = vim.treesitter.get_parser(0, 'markdown'):parse()[1]:root()
    ---@diagnostic disable-next-line: missing-parameter
    for id, node in state.config.query:iter_captures(root, 0) do
        local capture = state.config.query.captures[id]
        local value = vim.treesitter.get_node_text(node, 0)
        local start_row, start_col, end_row, end_col = node:range()

        if capture == 'heading' then
            local level = #value
            local heading = list.cycle(state.config.headings, level)
            local background = list.clamp_last(highlights.heading.backgrounds, level)
            local foreground = list.clamp_last(highlights.heading.foregrounds, level)

            local virt_text = { string.rep(' ', level - 1) .. heading, { foreground, background } }
            vim.api.nvim_buf_set_extmark(0, M.namespace, start_row, 0, {
                end_row = end_row + 1,
                end_col = 0,
                hl_group = background,
                virt_text = { virt_text },
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
        elseif capture == 'item' then
            local virt_text = { state.config.bullet, highlights.bullet }
            vim.api.nvim_buf_set_extmark(0, M.namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { virt_text },
                virt_text_pos = 'overlay',
            })
        elseif vim.tbl_contains({ 'table_head', 'table_delim', 'table_row' }, capture) then
            local row = value:gsub('|', '│')
            if capture == 'table_delim' then
                -- Order matters here, in particular handling inner intersections before left & right
                row = row:gsub('-', '─')
                    :gsub(' ', '─')
                    :gsub('─│─', '─┼─')
                    :gsub('│─', '├─')
                    :gsub('─│', '─┤')
            end

            local highlight = highlights.table.head
            if capture == 'table_row' then
                highlight = highlights.table.row
            end

            local virt_text = { row, highlight }
            vim.api.nvim_buf_set_extmark(0, M.namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                virt_text = { virt_text },
                virt_text_pos = 'overlay',
            })
        else
            -- Should only get here if user provides custom capture, currently unhandled
            vim.print('Unhandled capture: ' .. capture)
        end
    end
end

return M
