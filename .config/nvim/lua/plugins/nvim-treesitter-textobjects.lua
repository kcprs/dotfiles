return {
    enabled = false,
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("nvim-treesitter-textobjects").setup({
            select = {
                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,
                selection_modes = {
                    ["@parameter.outer"] = "v",
                    ["@function.outer"] = "<c-v>",
                },
            },
        })
    end,
}
