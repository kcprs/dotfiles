return {
    "lewis6991/gitsigns.nvim",
    opts = {
        -- See `:help gitsigns.txt`
        signs = {
            -- add = { text = "+" },
            -- change = { text = "~" },
            -- delete = { text = "_" },
            -- topdelete = { text = "‾" },
            -- changedelete = { text = "~" },
        },
        on_attach = require("custom.keymaps").gitsigns,
    },
}
