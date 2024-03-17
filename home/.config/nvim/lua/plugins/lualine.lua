return {
    "nvim-lualine/lualine.nvim",
    -- See `:help lualine.txt`
    opts = {
        options = {
            icons_enabled = false,
            theme = "auto",
            component_separators = "|",
            section_separators = "",
            disabled_filetypes = { "neo-tree" },
        },
        winbar = {
            lualine_c = {
                {
                    function()
                        local breadcrumbs = require("nvim-navic").get_location()
                        -- Add trailing space to ensure that something gets printed, even if breadcrumb string itself is empty
                        return breadcrumbs .. " "
                    end,
                    cond = function()
                        return require("nvim-navic").is_available()
                    end,
                },
            },
        },
    },
}
