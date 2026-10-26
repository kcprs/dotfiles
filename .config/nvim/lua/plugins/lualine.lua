local M = {}

function M.setup()
    -- See `:help lualine.txt`
    require("lualine").setup({
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
            "toggleterm", -- TODO: remove, not used
        },
    })
end

return M
