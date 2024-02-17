return {
  'stevearc/oil.nvim',
  config = function()
    require("oil").setup {
      view_options = {
        show_hidden = true,
      }
    }
    require("custom.keymaps").oil_set()
  end,
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
