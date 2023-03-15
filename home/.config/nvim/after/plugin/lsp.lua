-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp = require("lsp-zero")
lsp.preset("recommended")

-- Set up LSP keymaps on attach
lsp.on_attach(require("kcprs.keymap").setup_lsp)

-- Configure clangd
lsp.configure("clangd", {
    cmd = {
        "clangd",
        "--compile-commands-dir=_cc",
        "--clang-tidy",
        "--header-insertion=never"
    }
})

-- Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()

local function setup_diagnostics_signs()
    local signs = {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn", text = "" },
        { name = "DiagnosticSignHint", text = "" },
        { name = "DiagnosticSignInfo", text = "" },
    }

    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { text = sign.text, texthl = sign.name, numhl = "" })
    end

    return signs
end

-- Configure diagnostics. Must be called after lsp.setup()
vim.diagnostic.config {
    signs = {
        active = setup_diagnostics_signs(),
    },
}

-- TODO: LSP without lsp-zero: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#you-might-not-need-lsp-zero
