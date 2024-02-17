return {
  'nvim-lualine/lualine.nvim',
  -- See `:help lualine.txt`
  opts = {
    options = {
      icons_enabled = false,
      theme = 'auto',
      component_separators = '|',
      section_separators = '',
      disabled_filetypes = { "neo-tree" },
    },
    winbar = {
      lualine_c = {
        {
          "navic",
          color_correction = nil,
          naivc_opts = nil,
        }
      }
    }
  },
}
