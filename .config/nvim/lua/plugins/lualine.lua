return {
    "nvim-lualine/lualine.nvim",
    -- See `:help lualine.txt`
    opts = {
        options = {
            disabled_filetypes = { "DiffviewFiles" },
        },
        -- TODO integrate trouble?
        winbar = {
            lualine_c = {
                {
                    function()
                        return require("nvim-navic").get_location()
                    end,
                    draw_empty = true,
                },
            },
        },
        inactive_winbar = {
            lualine_c = {
                {
                    -- This is to avoid buffer contents jumping one line down when the window becomes active
                    function()
                        return ""
                    end,
                    draw_empty = true,
                }
            }
        },
        extensions = {
            "oil",
            "toggleterm",
        }
    },
}
