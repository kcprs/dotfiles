local status_ok_rt, rust_tools = pcall(require, "rust-tools")
if not status_ok_rt then
  return
end

rust_tools.setup{
  server = {
    on_attach = require("user.lsp.common").on_attach
  }
}

