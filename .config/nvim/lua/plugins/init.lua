local M = {}

local plugin_specs = {
    -- Main plugins
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

    {
        src = "https://github.com/saghen/blink.cmp", -- Deps: lazydev.nvim (Lua completion source in this config).
        -- use a release tag to download pre-built binaries
        version = vim.version.range("1.*"),
    },
    { src = "https://github.com/sindrets/diffview.nvim" }, -- Deps: nvim-web-devicons (optional file icons).
    { src = "https://github.com/stevearc/oil.nvim" }, -- Deps: nvim-web-devicons (optional file icons).
    { src = "https://github.com/nvim-lualine/lualine.nvim" }, -- Deps: nvim-web-devicons (optional), nvim-navic (breadcrumbs in this config).
    { src = "https://github.com/tpope/vim-sleuth" },
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = "https://github.com/mbbill/undotree" },
    { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
    {
        src = "https://github.com/kylechui/nvim-surround",
        version = vim.version.range("*"), -- Use for stability; omit to use `main` branch for the latest features
    },
    { src = "https://github.com/stevearc/conform.nvim" },
    { src = "https://github.com/saecki/crates.nvim", version = "stable" },
    { src = "https://github.com/hat0uma/csvview.nvim" },
    { src = "https://github.com/ibhagwan/fzf-lua" }, -- Deps: nvim-web-devicons (optional file icons).
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/RaafatTurki/hex.nvim" },
    { src = "https://github.com/NeogitOrg/neogit" }, -- Deps: plenary.nvim (required), diffview.nvim (optional Diff integration).
    { src = "https://github.com/rcarriga/nvim-notify" },
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" }, -- Deps: nvim-treesitter (parser management), nvim-web-devicons (optional).
    { src = "https://github.com/RRethy/vim-illuminate" },
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/theHamsta/nvim-dap-virtual-text" }, -- Deps: nvim-dap.
    { src = "https://github.com/rcarriga/nvim-dap-ui" }, -- Deps: nvim-dap, nvim-nio.
    { src = "https://github.com/mfussenegger/nvim-dap-python" }, -- Deps: nvim-dap.
    { src = "https://github.com/neovim/nvim-lspconfig" }, -- Deps: nvim-navic, nvim-navbuddy (attach callbacks in this config).
    { src = "https://github.com/j-hui/fidget.nvim", version = "v1.4.0" },
    { src = "https://github.com/SmiteshP/nvim-navbuddy" }, -- Deps: nvim-navic, nui.nvim.
    { src = "https://github.com/mrcjkb/rustaceanvim", version = vim.version.range("^9") }, -- Deps: nvim-dap (optional debugging), nvim-navic and nvim-navbuddy (attach callbacks in this config).
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/folke/lazydev.nvim" },

    -- Dependencies (main plugins can also be dependencies of other main plugins).
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/SmiteshP/nvim-navic" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },
}

function M.setup()
    -- Register dependencies before configuring the plugins that use them.
    vim.pack.add(plugin_specs)

    require("plugins.catppuccin").setup() -- Apply the colorscheme before other plugin setups.
    require("plugins.nvim-notify").setup() -- Set up notifications before their consumers.
    require("plugins.which-key").setup() -- Set up mapping groups before their consumers.
    require("plugins.lazydev").setup()
    require("plugins.blink-cmp").setup()
    require("plugins.diffview").setup()
    require("plugins.oil").setup()
    require("plugins.lualine").setup()
    require("plugins.vim-sleuth").setup()
    require("plugins.nvim-autopairs").setup()
    require("plugins.undotree").setup()
    require("plugins.indent-blankline").setup()
    require("plugins.nvim-surround").setup()
    require("plugins.conform").setup()
    require("plugins.crates").setup()
    require("plugins.csvview").setup()
    require("plugins.fzf-lua").setup()
    require("plugins.gitsigns").setup()
    require("plugins.hex").setup()
    require("plugins.neogit").setup()
    require("plugins.nvim-treesitter").setup()
    require("plugins.render-markdown").setup()
    require("plugins.vim-illuminate").setup()
    require("plugins.dap").setup()
    require("plugins.lsp").setup()
end

return M
