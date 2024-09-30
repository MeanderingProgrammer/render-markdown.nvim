---@class render.md.TreeSitter
local M = {}

---@class render.md.treesitter.Queries
M.queries = {
    markdown = [[
        (section) @section

        (atx_heading [
            (atx_h1_marker)
            (atx_h2_marker)
            (atx_h3_marker)
            (atx_h4_marker)
            (atx_h5_marker)
            (atx_h6_marker)
        ] @heading)
        (setext_heading) @heading

        [
            (thematic_break)
            (minus_metadata)
            (plus_metadata)
        ] @dash

        (fenced_code_block) @code

        [
            (list_marker_plus)
            (list_marker_minus)
            (list_marker_star)
        ] @list_marker

        [
            (task_list_marker_unchecked)
            (task_list_marker_checked)
        ] @checkbox

        (block_quote) @quote

        (pipe_table) @table
    ]],
    markdown_quote = [[
        [
            (block_quote_marker)
            (block_continuation)
        ] @quote_marker
    ]],
    inline = [[
        (code_span) @code

        (shortcut_link) @shortcut

        [
            (image)
            (email_autolink)
            (inline_link)
            (full_reference_link)
        ] @link
    ]],
}

---@param language string
---@param injection render.md.Injection?
function M.inject(language, injection)
    if injection == nil or not injection.enabled then
        return
    end

    local query = ''
    local files = vim.treesitter.query.get_files(language, 'injections')
    for _, file in ipairs(files) do
        local f = io.open(file, 'r')
        if f ~= nil then
            query = query .. f:read('*all') .. '\n'
            f:close()
        end
    end
    query = query .. injection.query
    pcall(vim.treesitter.query.set, language, 'injections', query)
end

return M
