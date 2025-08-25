---@class (exact) render.md.table.Config: render.md.base.Config
---@field preset render.md.table.Preset
---@field cell render.md.table.Cell
---@field cell_offset fun(ctx: render.md.table.cell.Context): integer
---@field padding integer
---@field min_width integer
---@field border string[]
---@field border_enabled boolean
---@field border_virtual boolean
---@field alignment_indicator string
---@field head string
---@field row string
---@field filler string
---@field style render.md.table.Style

---@class (exact) render.md.table.cell.Context
---@field node TSNode

---@enum render.md.table.Preset
local Preset = {
    none = 'none',
    round = 'round',
    double = 'double',
    heavy = 'heavy',
}

---@enum render.md.table.Cell
local Cell = {
    trimmed = 'trimmed',
    padded = 'padded',
    raw = 'raw',
    overlay = 'overlay',
}

---@enum render.md.table.Style
local Style = {
    full = 'full',
    normal = 'normal',
    none = 'none',
}

---@class render.md.table.Cfg
local M = {}

---@type render.md.table.Config
M.default = {
    -- Turn on / off pipe table rendering.
    enabled = true,
    -- Additional modes to render pipe tables.
    render_modes = false,
    -- Pre configured settings largely for setting table border easier.
    -- | heavy  | use thicker border characters     |
    -- | double | use double line border characters |
    -- | round  | use round border corners          |
    -- | none   | does nothing                      |
    preset = 'none',
    -- Determines how individual cells of a table are rendered.
    -- | overlay | writes completely over the table, removing conceal behavior and highlights |
    -- | raw     | replaces only the '|' characters in each row, leaving the cells unmodified |
    -- | padded  | raw + cells are padded to maximum visual width for each column             |
    -- | trimmed | padded except empty space is subtracted from visual width calculation      |
    cell = 'padded',
    -- Adjust the computed width of table cells using custom logic.
    cell_offset = function()
        return 0
    end,
    -- Amount of space to put between cell contents and border.
    padding = 1,
    -- Minimum column width to use for padded or trimmed cell.
    min_width = 0,
    -- Characters used to replace table border.
    -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal.
    -- stylua: ignore
    border = {
        '┌', '┬', '┐',
        '├', '┼', '┤',
        '└', '┴', '┘',
        '│', '─',
    },
    -- Turn on / off top & bottom lines.
    border_enabled = true,
    -- Always use virtual lines for table borders instead of attempting to use empty lines.
    -- Will be automatically enabled if indentation module is enabled.
    border_virtual = false,
    -- Gets placed in delimiter row for each column, position is based on alignment.
    alignment_indicator = '━',
    -- Highlight for table heading, delimiter, and the line above.
    head = 'RenderMarkdownTableHead',
    -- Highlight for everything else, main table rows and the line below.
    row = 'RenderMarkdownTableRow',
    -- Highlight for inline padding used to add back concealed space.
    filler = 'RenderMarkdownTableFill',
    -- Determines how the table as a whole is rendered.
    -- | none   | { enabled = false }        |
    -- | normal | { border_enabled = false } |
    -- | full   | uses all default values    |
    style = 'full',
}

---@return render.md.Schema
function M.schema()
    return require('render-markdown.config.base').schema({
        preset = { enum = Preset },
        cell = { enum = Cell },
        cell_offset = { type = 'function' },
        padding = { type = 'number' },
        min_width = { type = 'number' },
        border = { list = { type = 'string' } },
        border_enabled = { type = 'boolean' },
        border_virtual = { type = 'boolean' },
        alignment_indicator = { type = 'string' },
        head = { type = 'string' },
        row = { type = 'string' },
        filler = { type = 'string' },
        style = { enum = Style },
    })
end

return M
