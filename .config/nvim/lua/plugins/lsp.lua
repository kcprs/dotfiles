-- Default diagnostics settings
vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = true,
    virtual_text = true,
})


-- Override the default virtual text handler to hide diagnostics on the current line
local orig_virtual_text_handler = vim.diagnostic.handlers.virtual_text
vim.diagnostic.handlers.virtual_text = {
    show = function(namespace, bufnr, diagnostics, opts)
        local filtered_diagnostics = diagnostics;
        if vim.diagnostic.config().virtual_lines then
            local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- current line (zero-indexed)
            filtered_diagnostics = {}
            for _, diagnostic in ipairs(diagnostics) do
                if not (diagnostic.lnum <= cursor_line and cursor_line <= diagnostic.end_lnum) then
                    table.insert(filtered_diagnostics, diagnostic)
                end
            end
        end
        orig_virtual_text_handler.show(namespace, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(namespace, bufnr)
        orig_virtual_text_handler.hide(namespace, bufnr)
    end,
}

-- Refresh diagnostics when the cursor moves
local augroup_cursor = vim.api.nvim_create_augroup("Cursor", { clear = true })
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = augroup_cursor,
    callback = function()
        vim.diagnostic.show(nil, 0)
    end,
})

local function default_on_attach(client, bufnr)
    require("custom.keymaps").lsp_common(bufnr)

    if client.server_capabilities.documentSymbolProvider then
        -- Breadcrumbs plugin
        require("nvim-navic").attach(client, bufnr)

        -- Symbols navigator
        require("nvim-navbuddy").attach(client, bufnr)
    end
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

local function is_lsp_enabled_via_env(name)
    return string.find(os.getenv("NVIM_LSP") or "", name)
end

local servers = {
    clangd = {
        args = {
            "--clang-tidy",
            "--header-insertion=never"
        },
        on_attach = clangd_on_attach,
    },
    neocmake = {},
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
    ts_ls = {
        condition = function() return os.getenv("NVIM_LSP") == nil or is_lsp_enabled_via_env("ts_ls") end,
    },
    denols = {
        condition = function() return is_lsp_enabled_via_env("denols") end,
    },
    eslint = {
        condition = function() return is_lsp_enabled_via_env("eslint") end,
    },
    yamlls = {},
    bashls = {},
    marksman = {},

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
