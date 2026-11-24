local M = {}

function M.setup()
    -- TODO: Defer Which-key initialization to reduce startup time.
    require("which-key").setup({
        icons = {
            mappings = false,
        },
        notify = false,
    })
end

return M
