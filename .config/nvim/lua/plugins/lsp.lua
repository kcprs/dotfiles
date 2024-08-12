local function default_on_attach(client, bufnr)
    vim.diagnostic.config({
        virtual_text = require("custom.lsp").is_virtual_text_enabled(),
        update_in_insert = true,
    })

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

local function use_deno()
    local env_value = os.getenv("USE_DENO_LSP")
    if env_value then
        return true
    else
        return false
    end
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
    rust_analyzer = {
        -- Never explicitly call setup() - done by rustaceanvim
        condition = function() return false end,
    },
    taplo = {},
    tsserver = {
        condition = function() return not use_deno() end,
    },
    denols = {
        condition = use_deno
    },
    yamlls = {},
    bashls = {},

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
                local server_config = (servers[server_name] or {})

                -- If condition was given an it evaluates to false, do not set up anything
                if server_config.condition and not server_config.condition() then
                    return
                end

                local default_config = require('lspconfig')[server_name].document_config.default_config

                -- Add args to cmd
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
        })
    end,
}
