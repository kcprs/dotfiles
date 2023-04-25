local status_ok_lspconfig, lspconfig = pcall(require, "lspconfig")
if not status_ok_lspconfig then
  return
end

local servers = {
  {
    "sumneko_lua",
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.stdpath("config") .. "/lua"] = true,
          },
        },
      },
    },
    pre_on_attach = function(client, _)
      client.server_capabilities.document_formatting = false
    end,
  },
  { "pyright" }, -- TODO: allow bare string here
  -- { "rust_analyzer" }, -- Leave commented out, setup handled by rust-tools
}

local common = require("user.plugins.lsp.common")
common.setup()

for _, server in pairs(servers) do
  local name = server[1]

  local on_attach = (function()
    if server.pre_on_attach then
      return function(client, bufnr)
        server.pre_on_attach(client, bufnr)
        common.on_attach(client, bufnr)
      end
    else
      return common.on_attach
    end
  end)()

  local server_opts = {
    on_attach = on_attach,
    capabilities = common.capabilities,
    settings = server.settings,
  }

  lspconfig[name].setup(server_opts)
end
