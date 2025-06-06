return {
    "nvim-lualine/lualine.nvim",
    -- See `:help lualine.txt`
    opts = {
        options = {
            disabled_filetypes = { "DiffviewFiles" },
        },
        sections = {
            lualine_c = {
                {
                    "filename",
                    path = 1, -- 1: Relative path
                },
            },
        },
        -- TODO integrate trouble?
        winbar = {
            lualine_c = {
                "filename",
                {
                    "navic",
                    navic_opts = {
                        separator = "  ",
                    },
                },
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
        },
    },
}
