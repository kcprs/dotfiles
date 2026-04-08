return {
    enabled = false,
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("treesitter-context").setup({
            multiwindow = true,
            max_lines = "30%",
        })
    end,
}
