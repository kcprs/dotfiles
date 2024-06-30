local function default_on_attach(client, bufnr)
    require("custom.keymaps").lsp_common(bufnr)

    -- Breadcrumbs plugin
    if client.server_capabilities.documentSymbolProvider then
        require("nvim-navic").attach(client, bufnr)
    end

    -- Symbols navigator
    require("nvim-navbuddy").attach(client, bufnr)
end

local function rust_on_attach(client, bufnr)
    default_on_attach(client, bufnr)

    -- Overwrite Rust-specific keymaps
    require("custom.keymaps").lsp_rust(bufnr)
end

local function clangd_on_attach(client, bufnr)
    default_on_attach(client, bufnr)

    -- Overwrite clangd-specific keymaps
    require("custom.keymaps").lsp_clangd(bufnr)
end

local servers = {
    clangd = {
        args = {
            "--clang-tidy",
            "--header-insertion=never"
        },
        on_attach = clangd_on_attach,
    },
    cmake = {},
    lua_ls = {
        settings = {
            Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
            },
        }
    },
    pyright = {},
    rust_analyzer = {}, -- Note - configured using rustaceanvim
    taplo = {},
    tsserver = {},
    yamlls = {},

    -- html = { filetypes = { 'html', 'twig', 'hbs'} },
}

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",

        -- Useful status updates for LSP
        { "j-hui/fidget.nvim", tag = "v1.4.0", opts = {} },

        -- Additional lua configuration, makes nvim stuff amazing!
        "folke/neodev.nvim",

        -- Breadcrumbs and navigating symbols
        {
            "SmiteshP/nvim-navbuddy",
            dependencies = {
                "SmiteshP/nvim-navic",
                "MunifTanjim/nui.nvim",
            },
        },
        "hrsh7th/cmp-nvim-lsp",
        "nvim-navic",
        "nvim-navbuddy",

        {
            "mrcjkb/rustaceanvim",
            version = "^4",
            ft = { "rust" },
            config = function()
                vim.g.rustaceanvim = {
                    server = {
                        on_attach = rust_on_attach,
                    },
                }
            end,
        },
    },
    config = function()
        -- mason-lspconfig requires that these setup functions are called in this order
        -- before setting up the servers.
        require("mason").setup()
        require("mason-lspconfig").setup({
            -- Ensure the servers above are installed
            ensure_installed = vim.tbl_keys(servers),
        })

        -- Setup neovim lua configuration
        require("neodev").setup()

        -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

        require("mason-lspconfig").setup_handlers({
            function(server_name)
                local default_config = require('lspconfig')[server_name].document_config.default_config
                local server_config = (servers[server_name] or {})

                local cmd = default_config.cmd
                vim.list_extend(cmd, server_config.args or {})

                require("lspconfig")[server_name].setup({
                    capabilities = capabilities,
                    on_attach = server_config.on_attach or default_on_attach,
                    cmd = cmd,
                    settings = server_config.settings,
                    filetypes = server_config.filetypes,
                })
            end,

            ["rust_analyzer"] = function()
                -- Do nothing - rustaceanvim sets itself up
            end,
        })

        vim.diagnostic.config({
            virtual_text = true,
            update_in_insert = true,
        })
    end,
}
