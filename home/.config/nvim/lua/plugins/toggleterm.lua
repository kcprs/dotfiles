return {
  "akinsho/toggleterm.nvim",
  config = function ()
    require("toggleterm").setup{
      open_mapping = require("custom.keymaps").toggleterm_get_open_mapping(),
      terminal_mappings = true,
    }
    require("custom.keymaps").toggleterm_set()
  end
}
