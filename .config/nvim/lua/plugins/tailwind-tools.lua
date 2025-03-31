return {
    "luckasRanarison/tailwind-tools.nvim",
    build = ":UpdateRemotePlugins",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim", -- optional
        "neovim/nvim-lspconfig", -- optional
    },
    opts = {},
}
