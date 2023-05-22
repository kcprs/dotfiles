-- General options
vim.opt.relativenumber = true

-- Remaps
lvim.keys.insert_mode["jk"] = "<esc>"

-- Builtin plugin options
lvim.builtin.telescope.theme = "center"
lvim.builtin.telescope.pickers.buffers.initial_mode = "insert"

-- Other plugins
lvim.plugins = {
  -- Color themes
  { "catppuccin/nvim", name = "catppuccin" }, -- catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
  "folke/tokyonight.nvim",
  "cpea2506/one_monokai.nvim",
  "sainnhe/sonokai" -- has sub-styles - see: help sonokai-configuration
}

-- Colorscheme stuff
-- lvim.colorscheme = "tokyonight"
-- vim.o.background = "light" -- Tokyonight will automatically switch to light theme

-- tmp fix for broken colors, see: https://github.com/neovim/neovim/issues/22614
function ColorPlease(color)
  color = color or "tokyonight"
  vim.cmd.colorscheme(color)

  vim.api.nvim_set_option('background', 'dark')
end
vim.schedule(ColorPlease)
