return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim", -- required
        "sindrets/diffview.nvim", -- optional - Diff integration
    },
    config = function()
        require("neogit").setup({
            disable_line_numbers = false,
            graph_style = "unicode",
        })
        vim.keymap.set("n", "<leader>G", require("neogit").open, { desc = "open [G]it GUI" })
    end,
}
