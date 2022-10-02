local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer. Close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- Have packer manage itself
  use { "wbthomason/packer.nvim", commit = "00ec5adef58c5ff9a07f11f45903b9dbbaa1b422" } 

  -- Color schemes
  use { "https://gitlab.com/__tpb/monokai-pro.nvim", commit = "826d028edbcc7a8aadc0f7a32b32747d97575615" }

  -- cmp plugins
  use { "hrsh7th/nvim-cmp", tag = "v0.0.1" } -- The completion plugin
  use { "hrsh7th/cmp-buffer", commit = "62fc67a2b0205136bc3e312664624ba2ab4a9323" } -- buffer completions
  use { "hrsh7th/cmp-path", commit = "466b6b8270f7ba89abd59f402c73f63c7331ff6e" } -- path completions
  use { "saadparwaiz1/cmp_luasnip", commit = "a9de941bcbda508d0a45d28ae366bb3f08db2e36" } -- snippet completions
  use { "hrsh7th/cmp-nvim-lsp", commit = "affe808a5c56b71630f17aa7c38e15c59fd648a8" } -- LSP completions
  use { "hrsh7th/cmp-nvim-lua", commit = "d276254e7198ab7d00f117e88e223b4bd8c02d21" } -- completions for neovim Lua API

  -- LSP
  use { "neovim/nvim-lspconfig", tag = "v0.1.3" } -- enable LSP
  use { "williamboman/mason.nvim", commit = "59e6feeba9e07fd8228e20ed919d38b62af1d212" } -- simple to use language server installer
  -- use { "williamboman/mason-lspconfig.nvim", commit = "0051870dd728f4988110a1b2d47f4a4510213e31" } -- provides glue between mason and lspconfig
  use {
    "jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
    commit = "ff40739e5be6581899b43385997e39eecdbf9465",
    requires = { {"nvim-lua/plenary.nvim"} },
  }
  use { "RRethy/vim-illuminate", commit = "a2e8476af3f3e993bb0d6477438aad3096512e42" } -- highlight all occurences of word under cursor

  -- snippets
  use { "L3MON4D3/LuaSnip", tag = "v1.*" } --snippet engine

  -- Telescope
  use {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.0",
    requires = { {"nvim-lua/plenary.nvim"} },
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
