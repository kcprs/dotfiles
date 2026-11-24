local M = {}

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

---@return boolean
local function is_lsp_enabled_via_env(name)
    return string.find(os.getenv("NVIM_LSP") or "", name) ~= nil
end

---@class ServerConfig: vim.lsp.Config
---@field condition? fun(): boolean

---@type { [string]: ServerConfig }
local servers = {
    clangd = {
        cmd = {
            "clangd",
            "--clang-tidy",
            "--header-insertion=never",
            "--function-arg-placeholders=0",
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
        },
    },
    basedpyright = {},
    rust_analyzer = {
        -- rust-analyzer should be installed via rustup to keep
        -- it up to date with the Rust toolchain.
        --
        -- > rustup component add rust-analyzer
        -- Never explicitly call enable() - done by rustaceanvim
        condition = function()
            return false
        end,
    },
    taplo = {},
    ts_ls = {
        condition = function()
            return os.getenv("NVIM_LSP") == nil or is_lsp_enabled_via_env("ts_ls")
        end,
    },
    denols = {
        condition = function()
            return is_lsp_enabled_via_env("denols")
        end,
    },
    eslint = {
        condition = function()
            return is_lsp_enabled_via_env("eslint")
        end,
    },
    yamlls = {},
    bashls = {},
    marksman = {},
    gitlab_ci_ls = {},
    jsonls = {},
    copilot = {
        condition = function()
            return os.getenv("GH_COPILOT_ON") == "true"
        end,
    },

    -- html = { filetypes = { 'html', 'twig', 'hbs'} },
}

function M.setup()
    -- Default diagnostics settings
    require("custom.lsp").set_diagnostics_preset(1)

    -- Configure Rust before its filetype plugin starts the server.
    vim.g.rustaceanvim = {
        server = {
            on_attach = rust_on_attach,
        },
    }

    -- Useful status updates for LSP
    require("fidget").setup({})

    -- Breadcrumbs and navigating symbols are attached in default_on_attach.
    -- Server executables are installed externally and resolved through Neovim's PATH.

    for server, config in pairs(servers) do
        local on_attach = config.on_attach or default_on_attach

        -- "merge" pre-existing on_attach function - it may come from nvim-lspconfig
        if vim.lsp.config[server].on_attach ~= nil then
            local on_attach_1 = vim.lsp.config[server].on_attach
            local on_attach_2 = on_attach
            on_attach = function(client, bufnr)
                ---@diagnostic disable-next-line: need-check-nil
                on_attach_1(client, bufnr)
                on_attach_2(client, bufnr)
            end
        end

        config.on_attach = on_attach

        vim.lsp.config(server, config)

        if not config.condition or config.condition() then
            vim.lsp.enable(server)
        end
    end

    vim.lsp.inline_completion.enable()
end

return M
