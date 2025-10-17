return {
    -- Project is archived. Causes problems with the recent changes to lsp config
    enabled = false,
    "luckasRanarison/tailwind-tools.nvim",
    build = ":UpdateRemotePlugins",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "neovim/nvim-lspconfig", -- optional
    },
    opts = {},
}
