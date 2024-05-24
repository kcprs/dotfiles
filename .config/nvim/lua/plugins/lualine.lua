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
                "filename",
                {
                    "navic",
                    navic_opts = {
                        separator =  "  "
                    }
                }
            },
        },
        inactive_winbar = {
            lualine_c = {
                "filename",
            },
        },
        extensions = {
            "oil",
            "toggleterm",
        }
    },
}
