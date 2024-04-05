-- Enable the following language servers
--  -- Recommended Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
    clangd = {},
    pyright = {},
    rust_analyzer = {}, -- Note - configured using rustaceanvim
    -- tsserver = {},
    -- html = { filetypes = { 'html', 'twig', 'hbs'} },

    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}

local function create_mapping_fn(bufnr)
    return function(modes, keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        vim.keymap.set(modes, keys, func, { buffer = bufnr, desc = desc })
    end
end

local function keymaps_on_attach(bufnr)
    local keymap = create_mapping_fn(bufnr)

    keymap("n", "<leader>lr", vim.lsp.buf.rename, "[r]ename")
    keymap("n", "<leader>la", vim.lsp.buf.code_action, "code [a]ction")

    keymap("n", "gd", require("telescope.builtin").lsp_definitions, "[g]o to [d]efinition")
    keymap("n", "gD", vim.lsp.buf.declaration, "[g]o to [D]eclaration")
    keymap("n", "gr", require("telescope.builtin").lsp_references, "[g]o to [r]eferences")
    keymap("n", "gi", require("telescope.builtin").lsp_implementations, "[g]o to [i]mplementation")

    keymap("n", "<leader>lC", require("telescope.builtin").lsp_incoming_calls, "show [C]allers")
    keymap("n", "<leader>lc", require("telescope.builtin").lsp_outgoing_calls, "show [c]allees")

    keymap("n", "<leader>ls", require("telescope.builtin").lsp_document_symbols, "document [s]ymbols")
    keymap("n", "<leader>lS", require("telescope.builtin").lsp_dynamic_workspace_symbols, "workspace [S]ymbols")

    keymap("n", "<leader>lf", vim.lsp.buf.format, "[f]ormat")

    -- TODO Navbuddy keymaps

    -- See `:help K` for why this keymap
    keymap("n", "K", vim.lsp.buf.hover, "hover documentation")
    keymap({ "n", "i" }, "<c-j>", vim.lsp.buf.signature_help, "signature [h]elp")

    -- Lesser used LSP functionality

    -- keymap("n", '<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    -- keymap("n", '<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    -- keymap("n", '<leader>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, '[W]orkspace [L]ist Folders')
end

local function on_attach(client, bufnr)
    keymaps_on_attach(bufnr)

    -- Breadcrumbs plugin
    if client.server_capabilities.documentSymbolProvider then
        require("nvim-navic").attach(client, bufnr)
    end

    -- Symbols navigator
    require("nvim-navbuddy").attach(client, bufnr)
end

local function rust_on_attach(client, bufnr)
    on_attach(client, bufnr)

    -- Overwrite Rust-specific keymaps
    local keymap = create_mapping_fn(bufnr)

    keymap("n", "<leader>la", function()
        vim.cmd.RustLsp("codeAction")
    end, "code [a]ction")
    keymap("n", "<leader>ld", function()
        vim.cmd.RustLsp("renderDiagnostic")
    end, "open floating [d]iagnostic message")
    keymap("n", "<s-J>", function()
        vim.cmd.RustLsp("joinLines")
    end, "open floating [d]iagnostic message")
end

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
                require("lspconfig")[server_name].setup({
                    capabilities = capabilities,
                    on_attach = on_attach,
                    settings = servers[server_name],
                    filetypes = (servers[server_name] or {}).filetypes,
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
