local M = {}

-- Add indentation guides even on blank lines
function M.setup()
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    require("ibl").setup({})
end

return M
