return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            -- Override the color of relative line numbers - they are too dark by default
            custom_highlights = function(colors)
                return {
                    -- LineNr = { fg = colors.surface1 } -- Original
                    -- LineNr = { fg = colors.surface2 } -- Slightly brighter
                    LineNr = { fg = colors.lavender }, -- Same as line with cursor
                }
            end,
        })
        vim.cmd.colorscheme("catppuccin-mocha")
    end,
}
