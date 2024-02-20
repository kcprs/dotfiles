return {
    "lewis6991/gitsigns.nvim",
    opts = {
        -- See `:help gitsigns.txt`
        signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
            require("custom.keymaps").gitsigns_on_attach(bufnr)
        end,
    },
}
