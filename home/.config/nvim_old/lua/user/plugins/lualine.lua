local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local diff = {
  "diff",
  symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
  colored = false,
}

local diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  sections = { "error", "warn", "info", "hint" },
  update_in_insert = true,
}

local filename = {
  "filename",
  symbols = {
    modified = "",
    readonly = "(read-only)",
  },
}

local spaces = function()
  return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
end

lualine.setup {
  options = {
    disabled_filetypes = { "NvimTree" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", diff },
    lualine_c = { diagnostics, filename },
    lualine_x = { spaces, "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
}
