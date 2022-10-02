local status_ok, mason = pcall(require, "mason")
if not status_ok then
  vim.notify("mason not found")
  return
end

-- local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
-- if not status_ok then
  -- vim.notify("mason-lspconfig not found")
  -- return
-- end

mason.setup()
-- mason_lspconfig.setup()

local servers = {
  "sumneko_lua"
  -- "cssls",
  -- "html",
  -- "tsserver",
  -- "pyright",
  -- "bashls",
  -- "jsonls",
  -- "yamlls",
}

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  vim.notify("lspconfig not found")
  return
end


local opts = {}

for _, server in pairs(servers) do
  opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }

  if server == "sumneko_lua" then
    local sumneko_lua_opts = require "user.lsp.settings.sumneko_lua"
    opts = vim.tbl_deep_extend("force", sumneko_lua_opts, opts)
  end

  -- if server == "pyright" then
  -- local pyright_opts = require "user.lsp.settings.pyright"
  -- opts = vim.tbl_deep_extend("force", pyright_opts, opts)
  -- end

  lspconfig[server].setup(opts)
end

