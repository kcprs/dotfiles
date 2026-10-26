local M = {}

function M.setup()
    -- TODO: Defer Surround initialization to reduce startup time.
    require("nvim-surround").setup({})
end

return M
